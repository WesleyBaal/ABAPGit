CLASS zrwbfbpcl_picking_task_restart DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING picking_task TYPE zrwbfbps0003.

    METHODS restart
      RETURNING VALUE(return) TYPE bapiret2 .

  PRIVATE SECTION.

    DATA: picking_task TYPE zrwbfbps0003,
          task_header  TYPE zrwbfbpt0003,
          messages     TYPE bapiret2,
          task_item    TYPE TABLE OF zrwbfbpt0004.

    METHODS setup.
    METHODS build.

ENDCLASS.


CLASS zrwbfbpcl_picking_task_restart IMPLEMENTATION.


  METHOD constructor.

    me->picking_task = picking_task.
    me->setup( ).

  ENDMETHOD.


  METHOD setup.

    me->build( ).

  ENDMETHOD.


  METHOD build.

    LOOP AT me->picking_task-delivery_data INTO DATA(task).

      IF task-version <> 0.

        UPDATE zrwbfbpt0003 SET current_version = abap_false WHERE picking_task = task-picking_task
                                                               AND version      = task-version.

        me->task_header = VALUE #( picking_task       = task-picking_task
                                   version            = task-version + 1
                                   current_version    = abap_true
                                   id                 = task-id
                                   user_responsible   = abap_false
                                   create_date        = sy-datum
                                   create_time        = sy-uzeit
                                   status             = 'P'
                                   status_description = 'Em processamento' ).

        APPEND VALUE #( picking_task          = task-picking_task
                        version               = task-version + 1
                        id                    = task-id
                        delivery              = task-delivery
                        item                  = task-item
                        material              = task-material
                        material_description  = task-material_description
                        separate_quantity     = task-material_quantity
                        unit_measurement      = task-unit_measurement
                        quantity              = abap_false
                        unit                  = abap_false ) TO me->task_item.

      ELSE.

        IF task-picking_task IS NOT INITIAL.

          me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                            type   = 'E'
                                                            number = '032'
                                                            var1   = CONV #( task-picking_task  ) ). "A tarefa de separação é inicial e não pode ser reiniciada.
          RETURN.

        ELSE.

          me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                            type   = 'E'
                                                            number = '041' ).  "Não existe tarefa de separação para o item selecionado.
          RETURN.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD restart.

    DATA(previous_version) = task_header-version - 1.

    IF messages-type = 'E'.
      return = me->messages.
    ELSE.

      MODIFY zrwbfbpt0003 FROM me->task_header.
      MODIFY zrwbfbpt0004 FROM TABLE me->task_item.

      UPDATE zrwbfbpt0005 SET check_id = abap_true WHERE id           = task_header-id
                                                     AND picking_task = task_header-picking_task
                                                     AND version      = previous_version.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'S'
                                                        number = '038' ). "Tarefa de separação reiniciada!
    ENDIF.

  ENDMETHOD.

ENDCLASS.
