CLASS zrwbfbpcl_picking_task_hist DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        picking_task TYPE zrwbfbps0004 .
    METHODS get
      RETURNING
        VALUE(return) TYPE zrwbfbps0005_tab .
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: picking_task TYPE zrwbfbps0004,
          task_header  TYPE TABLE OF zrwbfbpt0003,
          task_item    TYPE TABLE OF zrwbfbpt0004,
          output       TYPE TABLE OF zrwbfbps0005.

    METHODS setup.
    METHODS get_data.
    METHODS build.

ENDCLASS.



CLASS zrwbfbpcl_picking_task_hist IMPLEMENTATION.


  METHOD constructor.

    me->picking_task = picking_task.
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->get_data( ).
    me->build( ).

  ENDMETHOD.


  METHOD get_data.

    SELECT * FROM zrwbfbpt0003 INTO TABLE me->task_header WHERE picking_task = me->picking_task-picking_task
                                                            AND deleted      = abap_false.

    IF sy-subrc = 0.

      SELECT * FROM zrwbfbpt0004 INTO TABLE me->task_item
         FOR ALL ENTRIES IN me->task_header WHERE picking_Task = me->task_header-picking_task
                                              AND version      > 0
                                              AND delivery     = me->picking_task-delivery
                                              AND item         = me->picking_task-item.

    ENDIF.


  ENDMETHOD.


  METHOD build.

    SORT me->task_item BY version DESCENDING picking_task ASCENDING.

    LOOP AT me->task_item INTO DATA(item) WHERE delivery = me->picking_task-delivery
                                            AND item     = me->picking_task-item.

      TRY.
          DATA(header) = me->task_header[ picking_task = item-picking_task
                                          version      = item-version ].
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      APPEND VALUE zrwbfbps0005( picking_task      = item-picking_task
                                 version           = item-version
                                 separate_quantity = item-separate_quantity
                                 unit_measurement  = item-unit_measurement
                                 quantity_separate = item-quantity
                                 unit              = item-unit
                                 user_responsible  = header-user_responsible
                                 color             = COND #( WHEN header-current_version = abap_true THEN 'C500' ) ) TO me->output.

    ENDLOOP.

  ENDMETHOD.


  METHOD get.

    return = me->output.

  ENDMETHOD.

ENDCLASS.
