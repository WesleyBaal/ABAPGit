*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0001I01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE ok_code.

    WHEN 'BACK'.
      CLEAR: ok_code.
      LEAVE TO SCREEN 0.

    WHEN 'EXECUTE'.
      CLEAR: ok_code.
      PERFORM execute_change.

  ENDCASE.

ENDMODULE.
