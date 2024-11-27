*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0003I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE ok_code.

    WHEN 'PRINT'.

      CLEAR: ok_code.
      PERFORM print_shipment_request_label.

    WHEN 'DISPLAY'.

      CLEAR: ok_code.
      PERFORM display_shipment_req_monitor.

    WHEN 'BACK'.

      CLEAR: ok_code.
      LEAVE TO SCREEN 0.

    WHEN 'CANCEL'.

      CLEAR: ok_code.
      PERFORM update_status_cancel.

    WHEN 'DELETE'.

      CLEAR: ok_code.
      PERFORM delete_shipment_request.

    WHEN 'REFRESH'.

      CLEAR: ok_code.
      PERFORM refresh_from_db.

    WHEN 'MONITOR'.

      CLEAR: ok_code.
      SET PARAMETER ID 'ZRWBFBP_ID' FIELD ''.
      CALL TRANSACTION 'ZRWBFBPTR0002'.

  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  CASE ok_code.

    WHEN 'BACK' OR 'CANC'.

      FREE MEMORY.
      CLEAR: ok_code,
             output_historic.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
