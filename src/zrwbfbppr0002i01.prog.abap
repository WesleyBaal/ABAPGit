
*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0002I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE ok_code.

    WHEN 'BACK'.

      CLEAR ok_code.
      LEAVE PROGRAM.

    WHEN 'CREATE'.

      control_screen = ok_code.
      control_alv = '9008'.

      PERFORM clear_output.
      PERFORM shipment_request_monitor.

      CALL SCREEN 9002.

    WHEN 'DISPLAY' OR 'ENTER'.

      control_screen = ok_code.
      control_alv = '9007'.

      PERFORM clear_output.
      PERFORM get_shipment_request.

      CALL SCREEN 9002.

    WHEN 'MODIFY'.

      control_screen = ok_code.

      PERFORM clear_output.
      PERFORM get_shipment_request.
      PERFORM modify_shipment_request.
      PERFORM check_editing_allowed.

      CALL SCREEN 9002.

    WHEN 'CANC'.

      CLEAR ok_code.
      LEAVE PROGRAM.

    WHEN 'DELETE'.

      CLEAR ok_code.
      PERFORM delete_shipment_request.

  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  IF control_parameter_id = 'TRACKING' AND
     ok_code = 'BACK'.

    SET PARAMETER ID 'ZRWBFBP_CHECK' FIELD ''.
    SET PARAMETER ID 'ZRWBFBP_ID'    FIELD ''.

    CLEAR: ok_code.
    LEAVE PROGRAM.

  ENDIF.

  CASE ok_code.

    WHEN 'ABA_1'.

      PERFORM set_subscreen USING 'ABA_F1'
                                  'ABA_1'
                                  '9003'.

    WHEN 'ABA_2'.

      PERFORM set_subscreen USING 'ABA_F2'
                                  'ABA_2'
                                  '9004'.

    WHEN 'ABA_3'.

      PERFORM set_subscreen USING 'ABA_F3'
                                  'ABA_3'
                                  '9005'.

    WHEN 'ABA_4'.

      PERFORM set_subscreen USING 'ABA_F4'
                                  'ABA_4'
                                  '9006'.

    WHEN 'BACK'.

      PERFORM set_subscreen USING 'ABA_F1'
                                  'ABA_1'
                                  '9003'.

      LEAVE TO SCREEN 0.

    WHEN 'NEXT'.

      control_screen = ok_code.

      CLEAR ok_code.
      PERFORM send_selected_row.

    WHEN 'RETURN'.

      CLEAR ok_code.
      PERFORM return_selected_row.

    WHEN 'VIEW_MODIF'.

      CLEAR: ok_code.
      PERFORM call_popup_to_confirm.
      PERFORM save_shipment_request.

    WHEN 'SAVE'.

      control_screen = ok_code.
      control_alv = 9007.

      CLEAR: ok_code.
      PERFORM save_shipment_request.

    WHEN 'CREATE_DB'.

      control_screen = ok_code.
      control_alv = 9007.

      CLEAR: ok_code.
      PERFORM create_shipment_request.

    WHEN 'MODIFY'.

      control_screen = ok_code.

      PERFORM clear_output.
      PERFORM get_shipment_request.
      PERFORM modify_shipment_request.

    WHEN 'DISPLAY'.

      control_screen = ok_code.
      control_alv = 9007.

    WHEN 'SEPARATE'.

      control_screen = ok_code.

      CLEAR: ok_code.
      PERFORM update_status_separate.

    WHEN 'CHECKOUT'.

      control_screen = ok_code.
      control_alv = 9007.

      CLEAR: ok_code.
      PERFORM update_status_checkout.

    WHEN 'PRINT'.

      CLEAR: ok_code.
      PERFORM print_shipment_request_label.

    WHEN 'CANCEL'.

      CLEAR: ok_code.
      PERFORM update_status_cancel.

    WHEN 'REFRESH'.

      CLEAR: ok_code.
      PERFORM refresh_from_db.

  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9009  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9009 INPUT.

  CASE ok_code.

    WHEN 'BACK' OR 'CANC'.

      FREE MEMORY.
      CLEAR: ok_code,
             output_historic.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
