*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0004F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  DATA(return) = NEW zrwbfbpcl_get_picking_task_se( picking_task )->get( IMPORTING task_data = task_data ).
  record_count =  lines( task_data-delivery_data ).

  IF record_count <= 5.
    control_page = 'DISABLE_ARROW'.
  ENDIF.

  IF return-number = 016.

    PERFORM display_messages USING return-number "Tarefa de separação não localizada!
                                   9001.
  ENDIF.

  TRY.
      DATA(task) = task_data-delivery_data[ 1 ].
    CATCH cx_sy_itab_line_not_found.
      CLEAR picking_task.
  ENDTRY.

  IF task-user_responsible IS INITIAL.
    PERFORM set_user_responsible USING task.
  ENDIF.

  PERFORM set_screen_fields USING 0.

  check_page = abap_true.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_USER_RESPONSIBLE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_user_responsible USING task TYPE zrwbfbps0004.

  IF task-version = 0.

    UPDATE zrwbfbpt0003 SET user_responsible = sy-uname WHERE picking_task = task-picking_task
                                                          AND version      = task-version .

    PERFORM update_version USING task.
    PERFORM refresh_from_db.

  ELSEIF task-version >= 1.

    UPDATE zrwbfbpt0003 SET user_responsible = sy-uname WHERE picking_task = task-picking_task
                                                          AND version      = task-version .

    PERFORM refresh_from_db.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_VERSION
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_version USING row TYPE zrwbfbps0004.

  UPDATE zrwbfbpt0003 SET version = 1 WHERE picking_task = row-picking_task
                                           AND version   = row-version.

  UPDATE zrwbfbpt0004 SET version = 1 WHERE picking_task = row-picking_task
                                        AND version      = row-version.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_SCREEN_FIELDS
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_screen_fields USING count_page TYPE i.

  DATA(input) = VALUE #( task_data-delivery_data[ count_page + 1 ]-unit_measurement OPTIONAL ).
  DATA(output) = zrwbfbpcl_utilities=>convert_output_by_convexit( convexit = 'CUNIT'
                                                                  value    =  input ).

  screen_fields = VALUE #( material1        = VALUE #( task_data-delivery_data[ count_page + 1 ]-material OPTIONAL )
                           material2        = VALUE #( task_data-delivery_data[ count_page + 2 ]-material OPTIONAL )
                           material3        = VALUE #( task_data-delivery_data[ count_page + 3 ]-material OPTIONAL )
                           material4        = VALUE #( task_data-delivery_data[ count_page + 4 ]-material OPTIONAL )
                           material5        = VALUE #( task_data-delivery_data[ count_page + 5 ]-material OPTIONAL )
                           quantity1        = VALUE #( task_data-delivery_data[ count_page + 1 ]-quantity OPTIONAL )
                           quantity2        = VALUE #( task_data-delivery_data[ count_page + 2 ]-quantity OPTIONAL )
                           quantity3        = VALUE #( task_data-delivery_data[ count_page + 3 ]-quantity OPTIONAL )
                           quantity4        = VALUE #( task_data-delivery_data[ count_page + 4 ]-quantity OPTIONAL )
                           quantity5        = VALUE #( task_data-delivery_data[ count_page + 5 ]-quantity OPTIONAL )
                           quantity_total1  = VALUE #( task_data-delivery_data[ count_page + 1 ]-material_quantity OPTIONAL )
                           quantity_total2  = VALUE #( task_data-delivery_data[ count_page + 2 ]-material_quantity OPTIONAL )
                           quantity_total3  = VALUE #( task_data-delivery_data[ count_page + 3 ]-material_quantity OPTIONAL )
                           quantity_total4  = VALUE #( task_data-delivery_data[ count_page + 4 ]-material_quantity OPTIONAL )
                           quantity_total5  = VALUE #( task_data-delivery_data[ count_page + 5 ]-material_quantity OPTIONAL )
                           unit1            = COND #( WHEN ( VALUE #( task_data-delivery_data[ count_page + 1 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit2            = COND #( WHEN ( VALUE #( task_data-delivery_data[ count_page + 2 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit3            = COND #( WHEN ( VALUE #( task_data-delivery_data[ count_page + 3 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit4            = COND #( WHEN ( VALUE #( task_data-delivery_data[ count_page + 4 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit5            = COND #( WHEN ( VALUE #( task_data-delivery_data[ count_page + 5 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           check_material   = ''
                           check_quantity   = ''
                           user_responsible = sy-uname
                           version          = VALUE #( task_data-delivery_data[ 1 ]-version OPTIONAL ) ) .

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_PAGINATION
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_pagination.

  IF count_page = 0.
    check_page = abap_true.
  ENDIF.

  IF control_screen = 'DOWN'.

    IF check_page = abap_true.
      count_page =  5.
      check_page = abap_false.
    ELSEIF check_page = abap_false.
      count_page = count_page + 5.
    ENDIF.

  ELSEIF control_screen = 'UP'.
    count_page = count_page - 5.
  ENDIF.

  PERFORM set_screen_fields USING count_page.

  IF screen_fields-material5 IS INITIAL.
    control_page = 'DOWN'.
  ELSE.
    control_page   = 'UP'.
    control_screen = 'DOWN'.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CHECK_COLLECTED_DATA
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_collected_data .

  DATA: quantity_total TYPE i.

  quantity_total = screen_fields-check_quantity.

  LOOP AT task_data-delivery_data ASSIGNING FIELD-SYMBOL(<delivery>) WHERE material = screen_fields-check_material.

    TRY.
        DATA(delivery_sum) = task_data-delivery_data_group[ material = <delivery>-material ].
      CATCH cx_sy_itab_line_not_found.
        CLEAR: delivery_sum.
    ENDTRY.

    IF delivery_sum-quantity = delivery_sum-separate_quantity.

      CLEAR: screen_fields-check_material, screen_fields-check_quantity.
      PERFORM display_messages USING 022 "Material separado!
                                    9002.
    ENDIF.

    IF screen_fields-check_quantity > delivery_sum-separate_quantity.

      CLEAR: screen_fields-check_material, screen_fields-check_quantity.
      PERFORM display_messages USING 021 "Quantidade conferida não está em conformidade com a tarefa de separação!
                                     9002.
    ENDIF.

    IF screen_fields-check_quantity <= delivery_sum-separate_quantity AND
       screen_fields-check_quantity IS NOT INITIAL.

      DO quantity_total TIMES.

        CHECK <delivery>-quantity < <delivery>-material_quantity.

        ADD 1 TO <delivery>-quantity.

        quantity_total = quantity_total - 1.

        DATA(print_data) = VALUE zrwbfbps0009( id                   = <delivery>-id
                                               picking_task         = <delivery>-picking_task
                                               version              = <delivery>-version
                                               material             = <delivery>-material
                                               material_description = <delivery>-material_description
                                               quantity             = <delivery>-quantity
                                               uom                  = <delivery>-unit_measurement ).

        NEW zrwbfbpcl_picking_task_print( print_data )->call_print(  ).

      ENDDO.

    ENDIF.

  ENDLOOP.

  IF <delivery> IS NOT ASSIGNED.

    CLEAR: screen_fields-check_material, screen_fields-check_quantity.
    PERFORM display_messages USING 020 "Material não localizado na tarefa de separação!
                                   9002.
  ENDIF.

  IF screen_fields-check_quantity IS NOT INITIAL.

    PERFORM save_data.
    PERFORM refresh_from_db.
    PERFORM check_pending_quantity.
    PERFORM set_screen_fields USING count_page.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CHECK_PENDING_QUANTITY
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_pending_quantity.

  LOOP AT task_data-delivery_data_group INTO DATA(delivery_sum).

    IF delivery_sum-quantity < delivery_sum-separate_quantity.
      RETURN.
    ENDIF.

  ENDLOOP.

  PERFORM finish.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_data.

  LOOP AT task_data-delivery_data INTO DATA(task).

    DATA(workarea) = VALUE zrwbfbpt0004( picking_task         = task-picking_task
                                         version              = task-version
                                         delivery             = task-delivery
                                         item                 = task-item
                                         id                   = task-id
                                         material             = task-material
                                         material_description = task-material_description
                                         separate_quantity    = task-material_quantity
                                         unit_measurement     = task-unit_measurement
                                         quantity             = task-quantity
                                         unit                 = task-unit
                                         check_quantity       = task-check_quantity ).

    UPDATE zrwbfbpt0004 SET quantity = workarea-quantity
                            unit     = task-unit_measurement WHERE delivery = task-delivery
                                                               AND item     = task-item
                                                               AND material = task-material
                                                               AND deleted  = abap_false.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form FINISH
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM finish.

  DATA return TYPE bapiret2.

  PERFORM display_message_confirm USING 019 "Deseja finalizar a conferência da tarefa de separação?
                               CHANGING return.

  IF return-type = 'Y'.

    PERFORM update_gross_weight.
    PERFORM update_picking_task_status.
    PERFORM display_messages USING 025 "Tarefa de separação finalizada com Êxito!
                                   9001.

  ELSEIF return-type = 'N'.

    CLEAR: screen_fields-check_material, screen_fields-check_quantity.
    LEAVE TO SCREEN 9002.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_GROSS_WEIGTH
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_gross_weight.

  DATA: gross_weight     TYPE zrwbfbpde0019,
        shipment_request TYPE zrwbfbpde0001.

  SELECT * FROM zrwbfbpt0002 INTO TABLE @DATA(delivery_data) WHERE picking_task = @picking_task
                                                               AND deleted      = @abap_false.

  IF sy-subrc = 0.

    SELECT * FROM zrwbfbpt0003 INTO TABLE @DATA(task_header)
       FOR ALL ENTRIES IN @delivery_data WHERE picking_task    = @delivery_data-picking_task
                                           AND current_version = @abap_true.

    IF sy-subrc = 0.

      SELECT * FROM zrwbfbpt0004 INTO TABLE @DATA(task_item)
         FOR ALL ENTRIES IN @task_header WHERE picking_task = @task_header-picking_task
                                           AND version      = @task_header-version.

    ENDIF.

    CLEAR: gross_weight.

    LOOP AT task_item INTO DATA(item) WHERE quantity <> ''.

      TRY.
          DATA(delivery) = delivery_data[ picking_task = item-picking_task
                                          delivery     = item-delivery
                                          item         = item-item ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR: delivery.
      ENDTRY.

      IF shipment_request IS INITIAL.
        shipment_request = delivery-id.
      ENDIF.

      gross_weight = gross_weight + ( delivery-gross_weight / delivery-material_quantity ) * item-quantity.

    ENDLOOP.

  ENDIF.

  UPDATE zrwbfbpt0001 SET gross_weight = gross_weight WHERE id = shipment_request.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_PICKING_TASK_STATUS
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_picking_task_status.

  UPDATE zrwbfbpt0003 SET status             = 'F'
                          status_description = 'Finalizado' WHERE picking_task    = picking_task
                                                              AND current_version = abap_true
                                                              AND deleted         = abap_false.

  CLEAR: picking_task.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form RESTART
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM restart.

  DATA: return TYPE bapiret2.

  PERFORM display_message_confirm USING 018 "Deseja reiniciar a tarefa de separação?
                               CHANGING return.

  IF return-type = 'Y'.

    DATA(update_user) = VALUE zrwbfbpt0003( picking_task     = VALUE #(  task_data-delivery_data[ 1 ]-picking_task OPTIONAL )
                                            version          = VALUE #(  task_data-delivery_data[ 1 ]-version OPTIONAL ) ).

    NEW zrwbfbpcl_picking_task_restart( task_data )->restart(  ).

    UPDATE zrwbfbpt0003 SET user_responsible = sy-uname WHERE picking_task = update_user-picking_task
                                                          AND version      = update_user-version .

    PERFORM refresh_from_db.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form UNLINK
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM unlink.

  DATA: return TYPE bapiret2.

  PERFORM display_message_confirm USING 017 "Deseja desvincular o usúario da tarefa de separação?
                                  CHANGING return.

  IF return-type = 'Y'.

    UPDATE zrwbfbpt0003 SET user_responsible = sy-uname WHERE picking_task = picking_task
                                                          AND version      = screen_fields-version .

    NEW zrwbfbpcl_picking_task_restart( task_data )->restart(  ).

  ELSEIF return-type = 'N'.
    LEAVE TO SCREEN 9002.
  ENDIF.

  CLEAR: picking_task.
  PERFORM display_messages USING 023 "Usuário desvinculado com Êxito!
                                 9001.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form REFRESH_FROM_DB
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_from_db.

  CLEAR: task_data.

  DATA(return) = NEW zrwbfbpcl_get_picking_task_se( picking_task )->get( IMPORTING task_data = task_data ).

  record_count =  lines( task_data-delivery_data ).

  IF record_count <= 5.
    control_page = 'DISABLE_ARROW'.
  ENDIF.

  PERFORM set_screen_fields USING count_page.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_CURSOR
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cursor.

  IF screen_fields-check_material IS INITIAL.
    SET CURSOR FIELD 'SCREEN_FIELDS-CHECK_MATERIAL'.
  ELSE.
    SET CURSOR FIELD 'SCREEN_FIELDS-CHECK_QUANTITY'.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGES
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_messages USING message_number TYPE any
                            screen         TYPE any.

  CALL FUNCTION 'ZSLAB_RF_MESSAGE'
    EXPORTING
      i_msgtyp = 'E'
      i_msgid  = 'ZRWBFBPMC0001'
      i_msgnr  = message_number.

  LEAVE TO SCREEN screen.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_MESSAGE_CONFIRM
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_message_confirm USING    message_number TYPE any
                             CHANGING return.

  CALL FUNCTION 'ZSLAB_RF_CONFIRM'
    EXPORTING
      message_type   = 'E'
      message_class  = 'ZRWBFBPMC0001'
      message_number = message_number
    IMPORTING
      return_code    = return.

ENDFORM.
