CLASS zrwbfbpcl_shipment_req_monitor DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        customer TYPE kunnr.

    METHODS get
      EXPORTING
        VALUE(shipment_request_monitor) TYPE zrwbfbps0003
      RETURNING
        VALUE(return)                   TYPE bapiret2.

  PRIVATE SECTION.

    DATA: customer             TYPE kunnr,
          messages             TYPE bapiret2,
          customer_master      TYPE kna1,
          status               TYPE dd07t,
          delivery_data        TYPE TABLE OF likp,
          item_data            TYPE TABLE OF lips,
          material_description TYPE TABLE OF makt,
          output_data          TYPE zrwbfbps0003.

    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.



CLASS zrwbfbpcl_shipment_req_monitor IMPLEMENTATION.


  METHOD constructor.

    me->customer = customer.
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->get_data(  ).
    me->build(  ).

  ENDMETHOD.


  METHOD get_data.

    SELECT SINGLE * FROM kna1 INTO me->customer_master WHERE kunnr = me->customer .

    IF sy-subrc = 0.

      SELECT * FROM likp INTO TABLE me->delivery_data WHERE kunnr = me->customer_master-kunnr.

      IF sy-subrc = 0.

        SELECT * FROM lips INTO TABLE me->item_data
           FOR ALL ENTRIES IN me->delivery_data WHERE vbeln = me->delivery_data-vbeln
                                                  AND lfimg <> ''.

        IF sy-subrc = 0.

          SELECT * FROM makt INTO TABLE me->material_description
             FOR ALL ENTRIES IN me->item_data WHERE matnr = me->item_data-matnr.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD build.

    TRY.
        DATA(delivery) = me->delivery_data[ kunnr = me->customer ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR delivery.
    ENDTRY.

    me->output_data-customer_data = VALUE #( status         = 'PL'
                                             customer       = me->customer_master-kunnr
                                             corporate_name = me->customer_master-name1
                                             plant          = me->customer_master-werks
                                             street         = me->customer_master-stras+4(31)
                                             address_number = me->customer_master-stras(3)
                                             district       = COND #( WHEN me->customer_master-ort02 IS INITIAL THEN 'Centro'
                                                                      ELSE me->customer_master-ort02 )
                                             zip_code       = me->customer_master-pstlz
                                             city           = me->customer_master-mcod3
                                             state          = me->customer_master-regio
                                             country        = me->customer_master-land1
                                             create_date    = sy-datlo
                                             create_time    = sy-timlo
                                             create_user    = sy-uname  ).

    LOOP AT me->item_data INTO DATA(item).

      TRY.
          DATA(material) = me->material_description[ matnr = item-matnr ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR: material.
      ENDTRY.

      APPEND VALUE #( delivery             = item-vbeln
                      item                 = item-posnr
                      material             = material-matnr
                      material_description = material-maktx
                      material_quantity    = item-lfimg
                      unit_measurement     = item-meins
                      gross_weight         = item-brgew
                      unit_weight          = item-gewei ) TO me->output_data-delivery_data .

    ENDLOOP.

    IF me->output_data IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '009'
                                                        var1   = CONV #( me->customer ) )."Cliente & não localizado no banco de dados!
    ENDIF.

  ENDMETHOD.


  METHOD get.

    IF me->messages-type = 'E'.
      return = me->messages.
    ELSE.
      shipment_request_monitor = me->output_data.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
