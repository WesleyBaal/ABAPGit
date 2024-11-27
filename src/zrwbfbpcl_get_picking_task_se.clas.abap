CLASS zrwbfbpcl_get_picking_task_se DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        picking_task TYPE zrwbfbpt0003-picking_task.

    METHODS get
      EXPORTING
        VALUE(task_data) TYPE zrwbfbps0003
      RETURNING
        VALUE(return)    TYPE bapiret2 .
  PRIVATE SECTION.

    DATA: picking_task  TYPE zrwbfbpt0003-picking_task,
          output_data   TYPE zrwbfbps0003,
          messages      TYPE bapiret2,
          header_data   TYPE TABLE OF zrwbfbpt0001,
          delivery_data TYPE TABLE OF zrwbfbpt0002,
          task_header   TYPE TABLE OF zrwbfbpt0003,
          task_item     TYPE TABLE OF zrwbfbpt0004.

    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.


CLASS zrwbfbpcl_get_picking_task_se IMPLEMENTATION.


  METHOD constructor.

    me->picking_task = picking_task.
    me->setup( ).

  ENDMETHOD.


  METHOD setup.

    me->get_data(  ).
    me->build(  ).

  ENDMETHOD.


  METHOD get_data.

    SELECT * FROM zrwbfbpt0002 INTO TABLE @DATA(delivery) WHERE picking_task = @me->picking_task.

    SELECT * FROM zrwbfbpt0001 INTO TABLE @DATA(header_shipment)
       FOR ALL ENTRIES IN @delivery WHERE id     = @delivery-id
                                      AND status = 'SE'.

    IF sy-subrc = 0.

      SELECT * FROM zrwbfbpt0003 INTO TABLE me->task_header WHERE picking_task    = me->picking_task
                                                              AND status          = 'P'
                                                              AND deleted         = abap_false
                                                              AND current_version = abap_true .

      IF sy-subrc = 0.

        SELECT * FROM zrwbfbpt0004 INTO TABLE me->task_item
           FOR ALL ENTRIES IN me->task_header WHERE version           = me->task_header-version
                                                AND picking_task      = me->task_header-picking_task
                                                AND separate_quantity <> 0000
                                                AND deleted           = abap_false.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD build.

    LOOP AT me->task_header INTO DATA(header).

      LOOP AT me->task_item INTO DATA(item) WHERE picking_task = header-picking_task.

        DATA(quantity_item) = VALUE zrwbfbps0007( picking_task         = item-picking_task
                                                  material             = item-material
                                                  quantity             = item-quantity
                                                  separate_quantity    = item-separate_quantity
                                                  unit_measurement     = item-unit_measurement ).

        COLLECT quantity_item INTO me->output_data-delivery_data_group.

        APPEND VALUE #( id                   = header-id
                        picking_task         = header-picking_task
                        delivery             = item-delivery
                        item                 = item-item
                        material             = item-material
                        material_description = item-material_description
                        material_quantity    = item-separate_quantity
                        unit_measurement     = item-unit_measurement
                        quantity             = item-quantity
                        unit                 = item-unit
                        user_responsible     = header-user_responsible
                        version              = header-version
                        status               = header-status
                        check_quantity       = item-check_quantity ) TO me->output_data-delivery_data.

      ENDLOOP.

    ENDLOOP.

    IF me->output_data IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '016' ). "Tarefa de separação não localizada!

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
