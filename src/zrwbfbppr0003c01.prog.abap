*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0003C01
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

    CLASS-METHODS: handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id
                e_column_id
                es_row_no.

    CLASS-METHODS handle_button_click FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING es_col_id
                es_row_no.

    CLASS-METHODS handle_toolbar_item FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object
                e_interactive.

    CLASS-METHODS handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

ENDCLASS.


*&---------------------------------------------------------------------*
*& Class HANDLE_EVENT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
CLASS handle_event IMPLEMENTATION.


*&---------------------------------------------------------------------*
*& Method HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  METHOD handle_button_click.

    IF es_col_id-fieldname = 'UPDATE_STATUS'.

      TRY.
          DATA(row) = output_header[ es_row_no-row_id ].
        CATCH cx_sy_itab_line_not_found.
          CLEAR:row.
          RETURN.
      ENDTRY.

      CASE row-status.

        WHEN 'PL'.
          PERFORM update_status_separate USING row.

        WHEN 'SE'.
          PERFORM update_status_checkout USING row.

      ENDCASE.

    ENDIF.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Method HANDLE_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  METHOD handle_hotspot_click .

    DATA: shipment_request_data TYPE zrwbfbps0003.

    DATA(field) = e_column_id.

    CASE field.

      WHEN 'ID'.
        TRY.
            DATA(shipment_request)  = output_header[ e_row_id-index ] .
            DATA(row) = VALUE lvc_t_row( ( index = e_row_id-index ) ).
          CATCH
            cx_sy_itab_line_not_found.
        ENDTRY .

        alv_grid_header->set_selected_rows( EXPORTING it_index_rows = row ).

        DATA(return) = NEW zrwbfbpcl_get_shipment_request( shipment_request-id )->get( IMPORTING shipment_request_data = shipment_request_data ).

        PERFORM display_messages USING return.

        shipment_request_id = shipment_request-id.
        check_status        = shipment_request-status.

        CLEAR: output_item.

        output_item =  shipment_request_data-delivery_data.

    ENDCASE.

    SET HANDLER handle_event=>handle_toolbar_item FOR alv_grid_item.
    SET HANDLER handle_event=>handle_user_command FOR alv_grid_item.

    layout_item = VALUE lvc_s_layo( grid_title = |Itens da solicitação de transporte { shipment_request_id }|
                                    zebra      = abap_true
                                    sel_mode   = 'A' ).

    alv_grid_item->refresh_table_display( ).
    alv_grid_item->set_frontend_layout( is_layout = layout_item ).

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Method HANDLE_TOOLBAR_ITEM
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  METHOD handle_toolbar_item.

    APPEND VALUE stb_button( butn_type = 3 ) TO e_object->mt_toolbar.

    IF check_status = 'PL'.

      APPEND VALUE stb_button( function  = 'CREATE_TASK'
                               icon      = icon_create
                               text      = 'Criar tarefa de separação' ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'RESTART_TASK'
                               icon      = icon_system_redo
                               text      = 'Reiniciar tarefa de separação'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'HISTORIC'
                               icon      = icon_history
                               text      = 'Histórico de versões'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

    ELSEIF check_status = 'SE'.

      APPEND VALUE stb_button( function  = 'CREATE_TASK'
                               icon      = icon_create
                               text      = 'Criar tarefa de separação'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'RESTART_TASK'
                               icon      = icon_system_redo
                               text      = 'Reiniciar tarefa de separação' ) TO e_object->mt_toolbar.

      APPEND VALUE stb_button( function  = 'HISTORIC'
                               icon      = icon_history
                               text      = 'Histórico de versões' ) TO e_object->mt_toolbar.

    ELSEIF check_status = 'CH' OR
           check_status = 'CO' OR
           check_status = abap_false.

      APPEND VALUE stb_button( function  = 'CREATE_TASK'
                               icon      = icon_create
                               text      = 'Criar tarefa de separação'
                               disabled  = abap_true ) TO e_object->mt_toolbar.

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
