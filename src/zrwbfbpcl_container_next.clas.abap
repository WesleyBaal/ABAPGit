CLASS zrwbfbpcl_container_next DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING selected_data TYPE zrwbfbps0003-delivery_data.

    METHODS next
      CHANGING deliveries TYPE zrwbfbps0003-delivery_data
               item_data  TYPE zrwbfbps0003-delivery_data.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: deliveries           TYPE zrwbfbps0003-delivery_data,
          output               TYPE zrwbfbps0003-delivery_data,
          delivery_range       TYPE RANGE OF lips-vbeln,
          item_data            TYPE TABLE OF lips,
          material_description TYPE TABLE OF makt.

    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.


CLASS zrwbfbpcl_container_next IMPLEMENTATION.


  METHOD constructor.

    me->deliveries = selected_data.
    me->setup( ).

  ENDMETHOD.


  METHOD setup.

    me->get_data( ).
    me->build( ).

  ENDMETHOD.


  METHOD get_data.

    me->delivery_range = VALUE #( FOR delivery IN me->deliveries
                                 ( sign   = 'I'
                                    option = 'EQ'
                                      low    = delivery-delivery ) ).

    CHECK delivery_range IS NOT INITIAL.

    SELECT * FROM lips INTO TABLE me->item_data WHERE vbeln IN me->delivery_range.

    IF sy-subrc = 0.

      SELECT * FROM makt INTO TABLE me->material_description
         FOR ALL ENTRIES IN me->item_data WHERE matnr = me->item_data-matnr.

    ENDIF.

  ENDMETHOD.


  METHOD build.

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
                      unit_weight          = item-gewei ) TO me->output .

    ENDLOOP.

  ENDMETHOD.


  METHOD next.

    LOOP AT me->output INTO DATA(selected).

      APPEND selected TO deliveries.
      DELETE item_data WHERE delivery = selected-delivery.

    ENDLOOP.

    SORT item_data  BY delivery.
    SORT deliveries BY picking_task DESCENDING delivery item .

  ENDMETHOD.

ENDCLASS.
