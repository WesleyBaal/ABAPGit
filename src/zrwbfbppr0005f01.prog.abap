*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0005F01
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

  DATA(return) = NEW zrwbfbpcl_get_picking_task_ch( shipment_request )->get( IMPORTING task_data = task_data ).

  record_count =  lines( task_data-delivery_data_group ).

  IF record_count <= 5.
    control_page = 'DISABLE_ARROW'.
  ENDIF.

  IF return-number = 027.
    PERFORM display_messages USING return-number "Solicitação de transporte não localizada!
                                   9001.
  ENDIF.

  PERFORM set_screen_fields USING 0.

  check_page = abap_true.

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

  DATA(input) = VALUE #( task_data-delivery_data_group[ count_page + 1 ]-unit_measurement OPTIONAL ).
  DATA(output) = zrwbfbpcl_utilities=>convert_output_by_convexit( convexit = 'CUNIT'
                                                                  value    =  input ).

  screen_fields = VALUE #( material1        = VALUE #( task_data-delivery_data_group[ count_page + 1 ]-material OPTIONAL )
                           material2        = VALUE #( task_data-delivery_data_group[ count_page + 2 ]-material OPTIONAL )
                           material3        = VALUE #( task_data-delivery_data_group[ count_page + 3 ]-material OPTIONAL )
                           material4        = VALUE #( task_data-delivery_data_group[ count_page + 4 ]-material OPTIONAL )
                           material5        = VALUE #( task_data-delivery_data_group[ count_page + 5 ]-material OPTIONAL )
                           quantity_total1  = VALUE #( task_data-delivery_data_group[ count_page + 1 ]-separate_quantity OPTIONAL )
                           quantity_total2  = VALUE #( task_data-delivery_data_group[ count_page + 2 ]-separate_quantity OPTIONAL )
                           quantity_total3  = VALUE #( task_data-delivery_data_group[ count_page + 3 ]-separate_quantity OPTIONAL )
                           quantity_total4  = VALUE #( task_data-delivery_data_group[ count_page + 4 ]-separate_quantity OPTIONAL )
                           quantity_total5  = VALUE #( task_data-delivery_data_group[ count_page + 5 ]-separate_quantity OPTIONAL )
                           unit1            = COND #( WHEN ( VALUE #( task_data-delivery_data_group[ count_page + 1 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit2            = COND #( WHEN ( VALUE #( task_data-delivery_data_group[ count_page + 2 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit3            = COND #( WHEN ( VALUE #( task_data-delivery_data_group[ count_page + 3 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit4            = COND #( WHEN ( VALUE #( task_data-delivery_data_group[ count_page + 4 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           unit5            = COND #( WHEN ( VALUE #( task_data-delivery_data_group[ count_page + 5 ]-unit_measurement OPTIONAL ) ) IS NOT INITIAL
                                                        THEN output
                                                          ELSE '' )
                           check_material   = ''
                           check_quantity   = ''
                           user_responsible = sy-uname
                           version          = VALUE #( task_data-delivery_data[ 1 ]-version OPTIONAL ) ) .

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CHECK_COLLECTED_DATA
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_collected_data.

  CHECK confirmed_id IS NOT INITIAL.

  TRY.
      DATA(check_confirmed_data) = task_data-confirmed_data[ confirmed_id = confirmed_id ].
    CATCH cx_sy_itab_line_not_found.
      CLEAR: check_confirmed_data.

      CLEAR:confirmed_id.
      PERFORM display_messages USING 040  "ID não vinculado à solicitação de transporte ou versão inativa.
                                     9002.
  ENDTRY.

  LOOP AT task_data-delivery_data_group ASSIGNING FIELD-SYMBOL(<delivery_sum>) WHERE material = check_confirmed_data-material.

    TRY.
        DATA(id_previous) = confirmed_id_table[ table_line = confirmed_id ].

        CLEAR:confirmed_id.
        PERFORM display_messages USING 028  "A confirmação para esta ID já foi validada!
                                       9002.

      CATCH cx_sy_itab_line_not_found.
        CLEAR: id_previous.
    ENDTRY.

    IF <delivery_sum>-separate_quantity > 0.
      APPEND confirmed_id TO confirmed_id_table.
      <delivery_sum>-separate_quantity = <delivery_sum>-separate_quantity - check_confirmed_data-quantity.
    ENDIF.

  ENDLOOP.

  CLEAR:confirmed_id.
  PERFORM check_pending_quantity.
  PERFORM set_screen_fields USING count_page.

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

    IF delivery_sum-separate_quantity > 0.
      RETURN.
    ENDIF.

  ENDLOOP.

  PERFORM finish.

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

  UPDATE zrwbfbpt0001 SET status             = 'CO'
                          status_description = 'Concluído' WHERE id = shipment_request.

  UPDATE zrwbfbpt0005 SET check_id = abap_true WHERE id = shipment_request.

  UPDATE zrwbfbpt0001 SET departure_date = sy-datum
                          departure_time = sy-timlo WHERE id = shipment_request.

  PERFORM clear_all.
  PERFORM display_messages USING 042  "Checkout finalizado com Êxito!
                                 9001.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form CLEAR_ALL
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_all.

  CLEAR: confirmed_id,
         confirmed_id_table,
         task_data-confirmed_data,
         confirmed_id,
         shipment_request.

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

  IF record_count <= 5.
    control_page = 'DISABLE_ARROW'.
  ENDIF.

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
