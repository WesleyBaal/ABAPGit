CLASS zrwbfbpcl_shipment_req_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        shipment_request TYPE zrwbfbpt0001-id .

    METHODS call_print .

  PRIVATE SECTION.

    DATA: header_data      TYPE zrwbfbpt0001,
          delivery_data    TYPE TABLE OF zrwbfbpt0002,
          picking_header   TYPE TABLE OF zrwbfbpt0003,
          picking_item     TYPE TABLE OF zrwbfbpt0004,
          item_data        TYPE TABLE OF zrwbfbps0004,
          shipment_request TYPE zrwbfbpt0001-id.

    METHODS setup.
    METHODS get_data.
    METHODS build.
    METHODS print.

ENDCLASS.



CLASS zrwbfbpcl_shipment_req_print IMPLEMENTATION.

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
                                                             AND deleted = abap_false
                                                             AND status  <> 'CA'.
    IF sy-subrc = 0.

      SELECT * FROM zrwbfbpt0002 INTO TABLE me->delivery_data WHERE id      = me->header_data-id
                                                                AND deleted = abap_false.

      IF sy-subrc = 0.

        SELECT * FROM zrwbfbpt0003 INTO TABLE me->picking_header
           FOR ALL ENTRIES IN me->delivery_data WHERE picking_task    = me->delivery_data-picking_task
                                                  AND current_version = abap_true.

        IF sy-subrc = 0.

          SELECT * FROM zrwbfbpt0004 INTO TABLE me->picking_item
             FOR ALL ENTRIES IN me->picking_header WHERE picking_task = me->picking_header-picking_task
                                                     AND version      = me->picking_header-version .

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD call_print.

    me->print(  ).

  ENDMETHOD.


  METHOD build.

    TRANSLATE me->header_data-status_description TO UPPER CASE.

    LOOP AT me->delivery_data INTO DATA(delivery).

      TRY.
          DATA(header) = me->picking_header[ picking_task = delivery-picking_task ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR: header.
      ENDTRY.

      TRY.
          DATA(item) = me->picking_item[ delivery     = delivery-delivery
                                         item         = delivery-item
                                         picking_task = header-picking_task
                                         version      = header-version ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR: item.
      ENDTRY.

      DATA(gross_weight) = ( delivery-gross_weight / delivery-material_quantity ) * item-quantity.

      APPEND VALUE #( delivery             = delivery-delivery
                      item                 = delivery-item
                      id                   = delivery-id
                      picking_task         = delivery-picking_task
                      material             = delivery-material
                      material_description = delivery-material_description
                      material_quantity    = delivery-material_quantity
                      unit_measurement     = delivery-unit_measurement
                      quantity             = item-quantity
                      unit                 = COND #( WHEN item-quantity IS NOT INITIAL THEN item-unit
                                                     ELSE '' )
                      gross_weight         = COND #( WHEN gross_weight IS NOT INITIAL THEN gross_weight
                                                     ELSE '0.000' )
                      unit_weight          = COND #( WHEN item-quantity IS NOT INITIAL THEN delivery-unit_weight
                                                     ELSE '' ) ) TO me->item_data.

    ENDLOOP.

  ENDMETHOD.


  METHOD print.

    DATA: name    TYPE rs38l_fnam,
          options TYPE ssfcompop,
          control TYPE ssfctrlop,
          printer TYPE rspopname.

    options = VALUE #( tddest   = printer
                       tdnoprev = 'X'
                       tdimmed  = 'X' ).

    control = VALUE #( no_dialog = 'X'
                       device    = 'PRINTER' ).

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname = 'ZRWBFBPSF0001'
      IMPORTING
        fm_name  = name.

    CALL FUNCTION name
      EXPORTING
        control_parameters = control
        output_options     = options
        user_settings      = space
        header             = me->header_data
      TABLES
        item_data          = me->item_data
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

  ENDMETHOD.

ENDCLASS.
