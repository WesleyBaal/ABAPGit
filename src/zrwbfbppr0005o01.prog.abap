*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0005O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.

  SET PF-STATUS 'PF9001'.
  SET TITLEBAR 'T9001'.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.

  SET PF-STATUS 'PF9002'.
  SET TITLEBAR 'T9002'.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module FIELD_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE field_control OUTPUT.

  IF control_page = 'UP' AND count_page = 0.

    LOOP AT SCREEN.

      IF screen-name = 'UP'.
        screen-active = 0.
      ENDIF.

      MODIFY SCREEN.

    ENDLOOP.

  ELSEIF control_page = 'DOWN'.

    LOOP AT SCREEN.

      IF screen-name = 'DOWN'.
        screen-active = 0.
      ENDIF.

      MODIFY SCREEN.

    ENDLOOP.

  ELSEIF control_page = 'DISABLE_ARROW'.

    LOOP AT SCREEN.

      IF screen-name = 'DOWN'.
        screen-active = 0.
      ENDIF.

      IF screen-name = 'UP'.
        screen-active = 0.
      ENDIF.

      MODIFY SCREEN.

    ENDLOOP.

  ENDIF.

ENDMODULE.
