CLASS zrwbfbpcl_picking_task_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        transport_data TYPE zrwbfbps0003 .

    METHODS create
      RETURNING VALUE(return) TYPE bapiret2.

  PRIVATE SECTION.

    DATA: transport_data TYPE zrwbfbps0003,
          picking_task   TYPE char10,
          task_header    TYPE zrwbfbpt0003,
          messages       TYPE bapiret2,
          task_item      TYPE TABLE OF zrwbfbpt0004,
          deliveries     TYPE TABLE OF zrwbfbpt0002.

    METHODS setup.
    METHODS number_next.
    METHODS build.

ENDCLASS.


CLASS zrwbfbpcl_picking_task_create IMPLEMENTATION.


  METHOD constructor.

    me->transport_data = transport_data.
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->number_next(  ).
    me->build( ).

  ENDMETHOD.


  METHOD number_next.

    DATA: nr_range_nr TYPE nrnr,
          object      TYPE inri-object,
          number      TYPE p.

    CLEAR: me->picking_task.

    object      = 'ZRWBFBP_TS'.
    nr_range_nr = '01'.

    CALL FUNCTION 'NUMBER_RANGE_ENQUEUE'
      EXPORTING
        object           = object
      EXCEPTIONS
        foreign_lock     = 1
        object_not_found = 2
        system_failure   = 3
        OTHERS           = 4.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = nr_range_nr
        object                  = object
      IMPORTING
        number                  = number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    CALL FUNCTION 'NUMBER_RANGE_DEQUEUE'
      EXPORTING
        object = object.

    me->picking_task = number.

  ENDMETHOD.


  METHOD build.

    me->task_header = VALUE #( picking_task       = me->picking_task
                               version            = ''
                               id                 = VALUE #(  me->transport_data-delivery_data[ 1 ]-id OPTIONAL )
                               user_responsible   = ''
                               create_date        = sy-datum
                               create_time        = sy-uzeit
                               current_version    = abap_true
                               status             = 'P'
                               status_description = 'Em processamento').

    LOOP AT me->transport_data-delivery_data INTO DATA(delivery).

      UPDATE zrwbfbpt0002 SET picking_task = me->picking_task WHERE id       = delivery-id
                                                                AND delivery = delivery-delivery
                                                                AND item     = delivery-item.

      APPEND VALUE #( picking_task         = me->picking_task
                      version              = 0
                      id                   = delivery-id
                      delivery             = delivery-delivery
                      item                 = delivery-item
                      material             = delivery-material
                      material_description = delivery-material_description
                      separate_quantity    = delivery-material_quantity
                      unit_measurement     = delivery-unit_measurement
                      quantity             = delivery-quantity
                      unit                 = delivery-unit ) TO me->task_item.

    ENDLOOP.

    IF me->transport_data-delivery_data IS INITIAL.

      me->messages = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                        type   = 'E'
                                                        number = '036' ). "Já existe tarefa de separação para este item!

    ENDIF.

  ENDMETHOD.


  METHOD create.

    IF messages-type = 'E'.
      return = me->messages.
    ELSE.

      MODIFY zrwbfbpt0003 FROM me->task_header.
      MODIFY zrwbfbpt0004 FROM TABLE me->task_item.

      return = zrwbfbpcl_utilities=>get_bapiret2( id     = 'ZRWBFBPMC0001'
                                                  type   = 'S'
                                                  number = '013' ). "Tarefa de separação criada com êxito!
    ENDIF.

  ENDMETHOD.

ENDCLASS.
