CLASS zrwbfbpcl_shipment_req_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        shipment_request_data TYPE zrwbfbps0003 .

    METHODS save
      RETURNING VALUE(return) TYPE bapiret2.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: shipment_request_data TYPE zrwbfbps0003,
          header_data           TYPE zrwbfbpt0001,
          messages              TYPE bapiret2,
          task_header           TYPE TABLE OF zrwbfbpt0003,
          task_item             TYPE TABLE OF zrwbfbpt0004,
          delivery_data         TYPE TABLE OF zrwbfbpt0002,
          delivery              TYPE TABLE OF zrwbfbpt0002,
          regex                 TYPE REF TO cl_abap_regex,
          matcher               TYPE REF TO cl_abap_matcher.

    METHODS check_fields.
    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.


CLASS zrwbfbpcl_shipment_req_save IMPLEMENTATION.


  METHOD constructor.

    me->shipment_request_data = shipment_request_data.
    me->check_fields(  ).
    me->setup( ).

  ENDMETHOD.


  METHOD check_fields.

    CREATE OBJECT me->regex
      EXPORTING
        pattern     = '^[A-Z]{3}[0-9]{4}$'
        ignore_case = abap_false.

    me->matcher = me->regex->create_matcher( text = me->shipment_request_data-customer_data-plate_id ).

    IF me->shipment_request_data-customer_data-departure_date_planned IS INITIAL OR
       me->shipment_request_data-customer_data-plant                  IS INITIAL OR
       me->shipment_request_data-customer_data-departure_time_planned IS INITIAL OR
       me->shipment_request_data-customer_data-driver_name            IS INITIAL OR
       me->shipment_request_data-customer_data-plate_id               IS INITIAL OR
       me->shipment_request_data-customer_data-shipping_company_code  IS INITIAL OR
       me->shipment_request_data-customer_data-transport_type         IS INITIAL OR
       me->shipment_request_data-customer_data-vehicle_type           IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '044' ). "É obrigatório preencher todos os campos para salvar as alterações!

      RETURN.

    ENDIF.

    IF matcher->match( ) IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '039' ). "Placa de veículo inválida, alterações não gravadas.

      RETURN.

    ENDIF.

  ENDMETHOD.


  METHOD setup.

    me->get_data(  ).
    me->build( ).

  ENDMETHOD.


  METHOD get_data.

    CHECK me->shipment_request_data-delivery_data IS NOT INITIAL.

    SELECT * FROM zrwbfbpt0002 INTO TABLE me->delivery
       FOR ALL ENTRIES IN me->shipment_request_data-delivery_data WHERE id       = me->shipment_request_data-delivery_data-id
                                                                    AND delivery = me->shipment_request_data-delivery_data-delivery
                                                                    AND item     = me->shipment_request_data-delivery_data-item.

    SELECT * FROM zrwbfbpt0003 INTO TABLE me->task_header
       FOR ALL ENTRIES IN me->shipment_request_data-delivery_data WHERE picking_task    = me->shipment_request_data-delivery_data-picking_task
                                                                    AND current_version = abap_true
                                                                    AND deleted         = abap_false .

  ENDMETHOD.


  METHOD build.

    me->header_data = VALUE #( id                         = me->shipment_request_data-customer_data-id
                               status                     = me->shipment_request_data-customer_data-status
                               status_description         = me->shipment_request_data-customer_data-status_description
                               customer                   = me->shipment_request_data-customer_data-customer
                               corporate_name             = me->shipment_request_data-customer_data-corporate_name
                               plant                      = me->shipment_request_data-customer_data-plant
                               plant_description          = me->shipment_request_data-customer_data-plant_description
                               street                     = me->shipment_request_data-customer_data-street
                               address_number             = me->shipment_request_data-customer_data-address_number
                               district                   = me->shipment_request_data-customer_data-district
                               zip_code                   = me->shipment_request_data-customer_data-zip_code
                               city                       = me->shipment_request_data-customer_data-city
                               state                      = me->shipment_request_data-customer_data-state
                               country                    = me->shipment_request_data-customer_data-country
                               shipping_company_code      = me->shipment_request_data-customer_data-shipping_company_code
                               shipping_company           = me->shipment_request_data-customer_data-shipping_company
                               driver_name                = me->shipment_request_data-customer_data-driver_name
                               vehicle_type               = me->shipment_request_data-customer_data-vehicle_type
                               vehicle_type_description   = me->shipment_request_data-customer_data-vehicle_type_description
                               plate_id                   = me->shipment_request_data-customer_data-plate_id
                               transport_type             = me->shipment_request_data-customer_data-transport_type
                               transport_type_description = me->shipment_request_data-customer_data-transport_type_description
                               departure_date_planned     = me->shipment_request_data-customer_data-departure_date_planned
                               departure_time_planned     = me->shipment_request_data-customer_data-departure_time_planned
                               departure_date             = me->shipment_request_data-customer_data-departure_date
                               departure_time             = me->shipment_request_data-customer_data-departure_time
                               toll_value                 = me->shipment_request_data-customer_data-toll_value
                               currency                   = 'BRL'
                               gross_weight               = me->shipment_request_data-customer_data-gross_weight
                               unit_weight                = me->shipment_request_data-customer_data-unit_weight
                               create_date                = me->shipment_request_data-customer_data-create_date
                               create_time                = me->shipment_request_data-customer_data-create_time
                               create_user                = me->shipment_request_data-customer_data-create_user ) .

    LOOP AT me->shipment_request_data-delivery_data INTO DATA(output).

      TRY.
          DATA(gross_weight) = me->delivery[ id       = output-id
                                             delivery = output-delivery
                                             item     = output-item ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR:gross_weight.
      ENDTRY.

      APPEND VALUE #( picking_task         = output-picking_task
                      version              = output-version
                      id                   = output-id
                      delivery             = output-delivery
                      item                 = output-item
                      material             = output-material
                      material_description = output-material_description
                      separate_quantity    = output-material_quantity
                      unit_measurement     = output-unit_measurement
                      quantity             = output-quantity
                      unit                 = output-unit ) TO me->task_item.

      APPEND VALUE #( id                   = me->shipment_request_data-customer_data-id
                      picking_task         = output-picking_task
                      delivery             = output-delivery
                      item                 = output-item
                      material             = output-material
                      material_description = output-material_description
                      material_quantity    = output-material_quantity
                      unit_measurement     = output-unit_measurement
                      gross_weight         = gross_weight-gross_weight
                      unit_weight          = gross_weight-unit_weight ) TO me->delivery_data.

    ENDLOOP.

  ENDMETHOD.


  METHOD save.

    IF me->messages-type = 'E'.
      return = me->messages.
    ELSE.

      MODIFY zrwbfbpt0001 FROM me->header_data.
      MODIFY zrwbfbpt0002 FROM TABLE me->delivery_data.
      MODIFY zrwbfbpt0003 FROM TABLE me->task_header.
      MODIFY zrwbfbpt0004 FROM TABLE me->task_item.

      return = zrwbfbpcl_utilities=>get_bapiret2( id      = 'ZRWBFBPMC0001'
                                                  type    = 'S'
                                                  number  = '003'
                                                  var1    = CONV #( me->shipment_request_data-customer_data-id ) ) . "Solicitação de transporte & atualizada com êxito!

    ENDIF.

  ENDMETHOD.

ENDCLASS.
