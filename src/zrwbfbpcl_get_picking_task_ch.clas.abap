CLASS zrwbfbpcl_get_picking_task_ch DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        shipment_request TYPE zrwbfbpt0001-id .

    METHODS get
      EXPORTING
        VALUE(task_data) TYPE zrwbfbps0003
      RETURNING
        VALUE(return)    TYPE bapiret2 .

  PRIVATE SECTION.

    DATA: shipment_request TYPE zrwbfbpt0001-id,
          messages         TYPE bapiret2,
          header_data      TYPE TABLE OF zrwbfbpt0001,
          delivery_data    TYPE TABLE OF zrwbfbpt0002,
          task_header      TYPE TABLE OF zrwbfbpt0003,
          task_item        TYPE TABLE OF zrwbfbpt0004,
          confirmed_data   TYPE TABLE OF zrwbfbpt0005,
          output_data      TYPE zrwbfbps0003.

    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.



CLASS zrwbfbpcl_get_picking_task_ch IMPLEMENTATION.


  METHOD constructor.

    me->shipment_request = shipment_request.
    me->setup( ).

  ENDMETHOD.


  METHOD setup.

    me->get_data(  ).
    me->build(  ).

  ENDMETHOD.


  METHOD get_data.

    SELECT * FROM zrwbfbpt0001 INTO TABLE me->header_data WHERE id      = me->shipment_request
                                                            AND status  = 'CH'
                                                            AND deleted = abap_false.

    IF sy-subrc = 0.

      SELECT * FROM zrwbfbpt0002 INTO TABLE me->delivery_data
         FOR ALL ENTRIES IN me->header_data WHERE id      = me->header_data-id
                                              AND deleted = abap_false.
      IF sy-subrc = 0.

        SELECT * FROM zrwbfbpt0003 INTO TABLE me->task_header
           FOR ALL ENTRIES IN me->delivery_data WHERE id              = me->delivery_data-id
                                                  AND status          = 'F'
                                                  AND picking_task    = me->delivery_data-picking_task
                                                  AND current_version = abap_true.

        IF sy-subrc = 0.

          SELECT * FROM zrwbfbpt0004 INTO TABLE me->task_item
             FOR ALL ENTRIES IN me->task_header WHERE id       = me->task_header-id
                                                  AND quantity <> 0000
                                                  AND version  = me->task_header-version
                                                  AND deleted  = abap_false.

          IF sy-subrc = 0.

            SELECT * FROM zrwbfbpt0005 INTO TABLE me->confirmed_data
               FOR ALL ENTRIES IN me->task_item WHERE id       = me->task_item-id
                                                  AND check_id = abap_false.

          ENDIF.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD build.

    me->output_data-confirmed_data = CORRESPONDING #( me->confirmed_data ).

    LOOP AT me->task_header INTO DATA(header).

      LOOP AT me->task_item INTO DATA(item) WHERE picking_task = header-picking_task.

        DATA(quantity_item) = VALUE zrwbfbps0007( picking_task      = item-picking_task
                                                  material          = item-material
                                                  quantity          = item-separate_quantity
                                                  separate_quantity = item-quantity
                                                  unit_measurement  = item-unit_measurement ).

        COLLECT quantity_item INTO me->output_data-delivery_data_group.

      ENDLOOP.

    ENDLOOP.

    IF me->output_data IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '027' ). "Solicitação de transporte não localizada!

    ELSE.

      SORT me->output_data-delivery_data BY picking_task
                                            version
                                            delivery
                                            item.
    ENDIF.

  ENDMETHOD.


  METHOD get.

    IF messages-type = 'E'.
      return = me->messages.
    ELSE.
      task_data = me->output_data.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
