*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0002C01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Class HANDLE_EVENT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
CLASS handle_event DEFINITION.

  PUBLIC SECTION.
    CLASS-METHODS handle_toolbar_header FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object
                e_interactive.

    CLASS-METHODS handle_toolbar_transport FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object
                e_interactive.

    CLASS-METHODS handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

ENDCLASS.

CLASS handle_event IMPLEMENTATION.


*&---------------------------------------------------------------------*
*& Method HANDLE_TOOLBAR_HEADER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  METHOD handle_toolbar_header.

    APPEND VALUE stb_button( butn_type = 3 ) TO e_object->mt_toolbar.

    IF screen_fields-id IS NOT INITIAL AND
       output_transport IS NOT INITIAL AND
       control_screen <> 'CREATE'.

      APPEND VALUE stb_button( function  = 'CREATE_TASK'
                               icon      = icon_create
                               text      = 'Criar tarefa de separação' ) TO e_object->mt_toolbar.

    ELSE.

      APPEND VALUE stb_button( function  = 'CREATE_TASK'
                               icon      = icon_create
                               text      = 'Criar tarefa de separação'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Method HANDLE_TOOLBAR_TRANSPORT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  METHOD handle_toolbar_transport.

    APPEND VALUE stb_button( butn_type = 3 ) TO e_object->mt_toolbar.

    IF ( control_screen = 'MODIFY'   OR control_screen = 'SEPARATE'       OR
         control_screen = 'CHECKOUT' OR control_screen = 'RESTART_TASK' ) AND
         screen_fields-status = 'SE' .

      APPEND VALUE stb_button( function  = 'RESTART_TASK'
                               icon      = icon_system_redo
                               text      = 'Reiniciar tarefa de separação' ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'HISTORIC'
                               icon      = icon_history
                               text      = 'Histórico de versões' ) TO e_object->mt_toolbar.

    ELSEIF screen_fields-status = 'PL'.

      APPEND VALUE stb_button( function  = 'RESTART_TASK'
                               icon      = icon_system_redo
                               text      = 'Reiniciar tarefa de separação'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'HISTORIC'
                               icon      = icon_history
                               text      = 'Histórico de versões'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

    ELSE.

      APPEND VALUE stb_button( function  = 'RESTART_TASK'
                               icon      = icon_system_redo
                               text      = 'Reiniciar tarefa de separação'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'HISTORIC'
                               icon      = icon_history
                               text      = 'Histórico de versões' ) TO e_object->mt_toolbar.

    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Method HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  METHOD handle_user_command.

    CASE e_ucomm.

      WHEN 'CREATE_TASK'.

        control_screen = e_ucomm.

        CLEAR: e_ucomm.
        PERFORM picking_task_create.

      WHEN 'RESTART_TASK'.

        control_screen = e_ucomm.

        CLEAR: e_ucomm.
        PERFORM picking_task_restart.

      WHEN 'HISTORIC'.

        CLEAR: e_ucomm.
        PERFORM get_picking_task_historic.

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
