CLASS zrwbfbpcl_shipment_req_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        shipment_request_id TYPE zrwbfbpt0001-id .
    METHODS delete
      RETURNING
        VALUE(return) TYPE bapiret2 .
  PRIVATE SECTION.

    DATA: shipment_request_id TYPE zrwbfbpt0001-id,
          check_delete        TYPE char10,
          header_data         TYPE zrwbfbpt0001,
          delivery_data       TYPE TABLE OF zrwbfbpt0002,
          task_header         TYPE TABLE OF zrwbfbpt0003,
          task_item           TYPE TABLE OF zrwbfbpt0004.

    METHODS setup.
    METHODS get_data.

ENDCLASS.



CLASS zrwbfbpcl_shipment_req_delete IMPLEMENTATION.


  METHOD constructor.

    me->shipment_request_id = shipment_request_id.
    me->setup(  ).

  ENDMETHOD.


  METHOD setup.

    me->get_data(  ).

  ENDMETHOD.


  METHOD get_data.

    SELECT SINGLE * FROM zrwbfbpt0001 INTO me->header_data WHERE id      = me->shipment_request_id
                                                             AND deleted = abap_false.

    IF sy-subrc <> 0.
      me->check_delete = abap_true.
      RETURN.
    ENDIF.

    SELECT * FROM zrwbfbpt0002 INTO TABLE me->delivery_data WHERE id      = me->shipment_request_id
                                                              AND deleted = abap_false.

    IF sy-subrc = 0.

      SELECT * FROM zrwbfbpt0003 INTO TABLE me->task_header
         FOR ALL ENTRIES IN me->delivery_data WHERE id              = me->delivery_data-id
                                                AND picking_task    = me->delivery_data-picking_task
                                                AND current_version = abap_true
                                                AND deleted         = abap_false.

      IF sy-subrc = 0.

        SELECT * FROM zrwbfbpt0004 INTO TABLE me->task_item
           FOR ALL ENTRIES IN me->task_header WHERE picking_task = me->task_header-picking_task
                                                AND version      = me->task_header-version.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD delete.

    IF me->header_data-status = 'PL' AND me->check_delete = abap_false.

      UPDATE zrwbfbpt0001 SET deleted = abap_true WHERE id = me->shipment_request_id.
      UPDATE zrwbfbpt0002 SET deleted = abap_true WHERE id = me->shipment_request_id.

      LOOP AT me->task_item INTO DATA(item).

        UPDATE zrwbfbpt0003 SET deleted = abap_true WHERE picking_task = item-picking_task
                                                      AND version      = item-version.

        UPDATE zrwbfbpt0004 SET deleted = abap_true WHERE picking_task = item-picking_task
                                                      AND version      = item-version.

      ENDLOOP.

      return = zrwbfbpcl_utilities=>get_bapiret2( id      = 'ZRWBFBPMC0001'
                                                  type    = 'S'
                                                  number  = '006'
                                                  var1    = CONV #( me->shipment_request_id ) )."Solicitação de transporte & excluida com êxito.

    ELSEIF me->header_data-status <> 'PL' AND
           me->check_delete       = abap_false.

      DATA(status) = me->header_data-status_description.
      TRANSLATE status TO UPPER CASE.

      return = zrwbfbpcl_utilities=>get_bapiret2( id      = 'ZRWBFBPMC0001'
                                                  type    = 'E'
                                                  number  = '004'
                                                  var1    = CONV #( status )
                                                  var2    = CONV #( me->header_data-id ) )."Status & não permite eliminar a solicitação de transporte.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
