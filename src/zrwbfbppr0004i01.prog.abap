*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0004I01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE ok_code.

    WHEN 'BACK'.
      CLEAR: picking_task, ok_code.
      LEAVE PROGRAM.

    WHEN 'GO'.
      PERFORM get_data.
      CALL SCREEN 9002.

  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  CASE ok_code.

    WHEN 'BACK'.

      CLEAR: ok_code,
             control_page,
             picking_task.

      LEAVE TO SCREEN 9001.

    WHEN 'FINISH'.

      control_screen = ok_code.

      CLEAR: ok_code.
      PERFORM finish.

    WHEN 'UNLINK'.

      CLEAR: ok_code.
      PERFORM unlink.

    WHEN 'RESTART'.

      CLEAR: ok_code.
      PERFORM restart.

      LEAVE TO SCREEN 9002.

    WHEN 'ENTER'.

      CLEAR: ok_code.
      PERFORM check_collected_data.

    WHEN 'DOWN'.

      control_screen = ok_code.

      CLEAR: ok_code.
      PERFORM set_pagination.

    WHEN 'UP'.

      control_screen = ok_code.

      CLEAR: ok_code.
      PERFORM set_pagination.

  ENDCASE.

ENDMODULE.
