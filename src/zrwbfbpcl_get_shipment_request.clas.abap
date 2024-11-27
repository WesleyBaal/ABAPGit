CLASS zrwbfbpcl_get_shipment_request DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        shipment_request TYPE zrwbfbps0002-id .

    METHODS get
      EXPORTING
        VALUE(shipment_request_data) TYPE zrwbfbps0003
      RETURNING
        VALUE(return)                TYPE bapiret2.

  PRIVATE SECTION.

    DATA: shipment_request TYPE zrwbfbps0002-id,
          header_data      TYPE zrwbfbpt0001,
          messages         TYPE bapiret2,
          delivery_data    TYPE TABLE OF zrwbfbpt0002,
          task_header      TYPE TABLE OF zrwbfbpt0003,
          task_item        TYPE TABLE OF zrwbfbpt0004,
          output_data      TYPE zrwbfbps0003.

    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.



CLASS zrwbfbpcl_get_shipment_request IMPLEMENTATION.


  METHOD constructor.

    me->shipment_request = shipment_request.
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->get_data(  ).
    me->build(  ).

  ENDMETHOD.


  METHOD get_data.

    SELECT SINGLE * FROM zrwbfbpt0001 INTO me->header_data WHERE id      = me->shipment_request
                                                             AND deleted = abap_false.

    IF sy-subrc = 0 AND header_data-status <> 'CA'.

      SELECT * FROM zrwbfbpt0002 INTO TABLE me->delivery_data WHERE id      = header_data-id
                                                                AND deleted = abap_false.

      IF sy-subrc = 0.

        SELECT * FROM zrwbfbpt0003 INTO TABLE me->task_header
           FOR ALL ENTRIES IN me->delivery_data WHERE id              = me->delivery_data-id
                                                  AND picking_task    = me->delivery_data-picking_task
                                                  AND deleted         = abap_false
                                                  AND current_version = abap_true .

        IF sy-subrc = 0.

          SELECT * FROM zrwbfbpt0004 INTO TABLE me->task_item
             FOR ALL ENTRIES IN me->task_header WHERE id      = me->task_header-id
                                                  AND version = me->task_header-version.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD build.

    IF me->header_data-status <> 'CA'.

      me->output_data-customer_data = VALUE #( id                         = header_data-id
                                               customer                   = header_data-customer
                                               corporate_name             = header_data-corporate_name
                                               plant                      = header_data-plant
                                               plant_description          = header_data-plant_description
                                               street                     = header_data-street
                                               address_number             = header_data-address_number
                                               district                   = header_data-district
                                               zip_code                   = header_data-zip_code
                                               city                       = header_data-city
                                               state                      = header_data-state
                                               country                    = header_data-country
                                               plate_id                   = header_data-plate_id
                                               departure_date_planned     = header_data-departure_date_planned
                                               departure_time_planned     = header_data-departure_time_planned
                                               departure_date             = header_data-departure_date
                                               departure_time             = header_data-departure_time
                                               shipping_company_code      = header_data-shipping_company_code
                                               shipping_company           = header_data-shipping_company
                                               driver_name                = header_data-driver_name
                                               transport_type             = header_data-transport_type
                                               transport_type_description = header_data-transport_type_description
                                               vehicle_type               = header_data-vehicle_type
                                               vehicle_type_description   = header_data-vehicle_type_description
                                               status                     = header_data-status
                                               status_description         = header_data-status_description
                                               toll_value                 = COND #( WHEN header_data-toll_value IS INITIAL THEN '0.00'
                                                                                      ELSE header_data-toll_value )
                                               create_date                = header_data-create_date
                                               create_time                = header_data-create_time
                                               create_user                = header_data-create_user  ).

    ENDIF.

    LOOP AT me->delivery_data INTO DATA(delivery) WHERE id = header_data-id.

      TRY.
          DATA(header) = me->task_header[ id           = me->shipment_request
                                          picking_task = delivery-picking_task ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR header.
      ENDTRY.

      TRY.
          DATA(item) = me->task_item[ id           = header-id
                                      delivery     = delivery-delivery
                                      item         = delivery-item
                                      picking_task = header-picking_task
                                      version      = header-version ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR item.
      ENDTRY.

      DATA(gross_weight) = ( delivery-gross_weight / delivery-material_quantity ) * item-quantity.

      APPEND VALUE #( id                   = delivery-id
                      delivery             = delivery-delivery
                      item                 = delivery-item
                      material             = delivery-material
                      material_description = delivery-material_description
                      material_quantity    = delivery-material_quantity
                      unit_measurement     = delivery-unit_measurement
                      quantity             = item-quantity
                      unit                 = item-unit
                      user_responsible     = header-user_responsible
                      version              = header-version
                      status               = header-status
                      status_description   = header-status_description
                      icon                 = COND #( WHEN header-status = 'P'                     THEN icon_yellow_light
                                                     WHEN item-quantity <> item-separate_quantity THEN icon_yellow_light
                                                     WHEN header-status = 'F'                     THEN icon_green_light
                                                     ELSE '' )
                      gross_weight         = gross_weight
                      unit_weight          = delivery-unit_weight
                      picking_task         = delivery-picking_task ) TO me->output_data-delivery_data .

    ENDLOOP.

    SORT me->output_data-delivery_data BY picking_task delivery item ASCENDING.

    IF header_data-id IS INITIAL .

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '008' ). "Solicitação de transporte não localizada!

    ELSEIF header_data-status = 'CA'.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '043' ). "Solicitação de transporte cancelada, não é possivel visualizar!

    ENDIF.

  ENDMETHOD.


  METHOD get.

    IF me->messages-type = 'E'.
      return = me->messages.
    ELSE.
      shipment_request_data = me->output_data.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
