*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0002O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module  BUILD_ALV
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE build_alv OUTPUT.

  exclude_toolbar = VALUE #( ( '&DETAIL'     )
                             ( '&&SEP00'     )
                             ( '&PRINT_BACK' )
                             ( '&&SEP01'     )
                             ( '&&SEP02'     )
                             ( '&&SEP03'     )
                             ( '&FIND_MORE'  )
                             ( '&FIND'       )
                             ( '&&SEP04'     )
                             ( '&MB_SUM'     )
                             ( '&MB_SUBTOT'  )
                             ( '&&SEP05'     )
                             ( '&MB_EXPORT'  )
                             ( '&MB_VIEW'    )
                             ( '&COL0'       )
                             ( '&&SEP06'     )
                             ( '&INFO'       )
                             ( '&&SEP07'     ) ) .

  IF alv_grid_transport IS INITIAL.

    alv_container_transport = NEW #( container_name = 'TRANSPORT' ).
    alv_grid_transport      = NEW #( i_parent = alv_container_transport ).

    DATA(layout_transport) = VALUE lvc_s_layo( grid_title = |Itens da solicitação de transporte { screen_fields-id }|
                                               zebra      = abap_true
                                               sel_mode   = 'A' ).

    PERFORM create_fieldcatalog.

    SET HANDLER handle_event=>handle_toolbar_header FOR alv_grid_transport.
    SET HANDLER handle_event=>handle_user_command   FOR alv_grid_transport.

    DELETE fieldcat_transport WHERE fieldname = 'ID'.
    DELETE fieldcat_transport WHERE fieldname = 'DELETED'.

    CALL METHOD alv_grid_transport->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = layout_transport
        is_variant           = variant_item
        it_toolbar_excluding = exclude_toolbar
      CHANGING
        it_outtab            = output_transport
        it_fieldcatalog      = fieldcat_transport.

  ELSE.

    layout_transport = VALUE lvc_s_layo( grid_title = |Itens da solicitação de transporte { screen_fields-id }|
                                         zebra      = abap_true
                                         sel_mode   = 'A' ).

    alv_grid_transport->set_frontend_layout( is_layout = layout_transport ).
    alv_grid_transport->refresh_table_display( ).

  ENDIF.

  IF alv_grid_item IS INITIAL.

    alv_container_item = NEW #( container_name = 'ITEM' ).
    alv_grid_item      = NEW #( i_parent = alv_container_item ).

    DATA(layout_item) = VALUE lvc_s_layo( grid_title = 'Remessas'
                                          zebra      = abap_true
                                          sel_mode   = 'A' ).

    PERFORM create_fieldcatalog.

    CALL METHOD alv_grid_item->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = layout_item
        is_variant           = variant_item
        it_toolbar_excluding = exclude_toolbar
      CHANGING
        it_outtab            = output_item
        it_fieldcatalog      = fieldcat_item.

  ELSE.

    PERFORM create_fieldcatalog.

    CALL METHOD alv_grid_item->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = layout_item
        is_variant           = variant_item
        it_toolbar_excluding = exclude_toolbar
      CHANGING
        it_outtab            = output_item
        it_fieldcatalog      = fieldcat_item.

    alv_grid_item->set_frontend_layout( is_layout = layout_item ).
    alv_grid_item->refresh_table_display( ).

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module BUILD_ALV_FULL OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE build_alv_full OUTPUT.

  exclude_toolbar = VALUE #( ( '&DETAIL'     )
                             ( '&&SEP00'     )
                             ( '&PRINT_BACK' )
                             ( '&&SEP01'     )
                             ( '&&SEP02'     )
                             ( '&&SEP03'     )
                             ( '&FIND_MORE'  )
                             ( '&FIND'       )
                             ( '&&SEP04'     )
                             ( '&MB_SUM'     )
                             ( '&MB_SUBTOT'  )
                             ( '&&SEP05'     )
                             ( '&MB_EXPORT'  )
                             ( '&MB_VIEW'    )
                             ( '&COL0'       )
                             ( '&&SEP06'     )
                             ( '&INFO'       )
                             ( '&&SEP07'     ) ) .

  IF alv_grid IS INITIAL.

    alv_container = NEW #( container_name = 'DATA_TRANSPORT' ).
    alv_grid      = NEW #( i_parent = alv_container ).

    DATA(layout_display) = VALUE lvc_s_layo( grid_title = |Itens da solicitação de transporte { screen_fields-id }|
                                             zebra      = abap_true
                                             sel_mode   = 'A' ).

    SET HANDLER handle_event=>handle_toolbar_transport FOR alv_grid.
    SET HANDLER handle_event=>handle_user_command      FOR alv_grid.

    PERFORM create_fieldcatalog.

    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
        i_save               = 'A'
        is_layout            = layout_display
        is_variant           = variant_item
        it_toolbar_excluding = exclude_toolbar
      CHANGING
        it_outtab            = output_transport
        it_fieldcatalog      = fieldcat_transport.

  ELSE.

    layout_display = VALUE lvc_s_layo( grid_title = |Itens da solicitação de transporte { screen_fields-id }|
                                       zebra      = abap_true
                                       sel_mode   = 'A' ).

    SET HANDLER handle_event=>handle_toolbar_transport FOR alv_grid.
    SET HANDLER handle_event=>handle_user_command      FOR alv_grid.

  ENDIF.

  alv_grid->set_frontend_layout( is_layout = layout_display ).
  alv_grid->refresh_table_display( ).

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module BUILD_ALV_HISTORIC OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE build_alv_historic OUTPUT.

  IF alv_grid_historic IS INITIAL.

    docking_container = NEW cl_gui_docking_container( extension = '2500' ).
    alv_grid_historic = NEW cl_gui_alv_grid( i_parent = docking_container ).

    DATA(layout_historic) = VALUE lvc_s_layo( grid_title =  |Remessa: { line-delivery } Item: { line-item } - { line-material }|
                                              zebra      = abap_true
                                              no_toolbar = abap_true
                                              info_fname = 'COLOR').

    PERFORM create_fieldcatalog.

    CALL METHOD alv_grid_historic->set_table_for_first_display
      EXPORTING
        i_save          = 'A'
        is_layout       = layout_historic
      CHANGING
        it_outtab       = output_historic
        it_fieldcatalog = fieldcat_historic.

  ENDIF.

  layout_historic = VALUE lvc_s_layo( grid_title =  |Remessa: { line-delivery } Item: { line-item } - { line-material }|
                                      zebra      = abap_true
                                      no_toolbar = abap_true
                                      info_fname = 'COLOR').

  alv_grid_historic->set_frontend_layout( is_layout = layout_historic ).
  alv_grid_historic->refresh_table_display( ).

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module FIELD_CONTROL OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE field_control OUTPUT.

  IF control_screen = 'SAVE'       OR
     control_screen = 'DISPLAY'    OR
     control_screen = 'ENTER'      OR
     control_screen = 'CREATE_DB'  OR
     control_screen = 'CHECKOUT'   AND
   ( screen_fields-status = 'CH'   OR
     screen_fields-status = 'CO' ).

    LOOP AT SCREEN.

      IF screen-name = 'SCREEN_FIELDS-PLANT'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group1 = 'G1'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group3 = 'G3'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

  ELSEIF control_screen = 'MODIFY' AND
         screen_fields-status = 'PL'.

    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input  = 1.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSEIF control_screen = 'MODIFY' AND
         screen_fields-status = 'SE'.

    LOOP AT SCREEN.

      IF screen-name = 'SCREEN_FIELDS-PLANT'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group2 = 'G2'.
        screen-input = 1.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group4 = 'G4'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.

      IF screen-name = 'SCREEN_FIELDS-PLANT'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.

    ENDLOOP.

  ELSEIF screen_fields-status = 'CH'.

    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSEIF screen_fields-status = 'CO'.

    LOOP AT SCREEN.
      IF screen-group1 = 'G1'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.

  GET PARAMETER ID 'ZRWBFBP_CHECK' FIELD control_parameter_id.
  GET PARAMETER ID 'ZRWBFBP_ID'    FIELD screen_fields-id.

  SET PF-STATUS 'PF9001'.
  SET TITLEBAR  'T9001'.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.

  IF control_screen = 'CREATE'.

    SET PF-STATUS 'PF9008'.
    SET TITLEBAR  'T9001'.

  ELSEIF ( screen_fields-status = 'PL'   OR
           screen_fields-status = 'SE' ) AND
         ( control_screen = 'SAVE'       OR
           control_screen = 'VIEW_MODIF' OR
           control_screen = 'CREATE_DB'  OR
           control_screen = 'DISPLAY'    OR
           control_screen = 'ENTER' ) .

    SET PF-STATUS 'PF9003'.
    SET TITLEBAR  'T9002'.

  ELSEIF control_screen = 'SEPARATE' AND
         screen_fields-status = 'SE'.

    SET PF-STATUS 'PF9006'.
    SET TITLEBAR  'T9002'.

  ELSEIF ( control_screen = 'DISPLAY'    OR
           control_screen = 'ENTER'      OR
           control_screen = 'REFRESH'    OR
           control_screen = 'CHECKOUT' ) AND
           screen_fields-status = 'CH' .

    SET PF-STATUS 'PF9004'.
    SET TITLEBAR  'T9002'.

  ELSEIF ( control_screen = 'DISPLAY'    OR
           control_screen = 'ENTER'      OR
           control_screen = 'REFRESH'    OR
           control_screen = 'CHECKOUT' ) AND
           screen_fields-status = 'CO' .

    SET PF-STATUS 'PF9002'.
    SET TITLEBAR  'T9002'.

  ELSEIF control_screen = 'MODIFY' AND
         screen_fields-status = 'PL'.

    SET PF-STATUS 'PF9005'.
    SET TITLEBAR  'T9003'.

  ELSEIF control_screen = 'MODIFY' AND
         screen_fields-status = 'SE'.

    SET PF-STATUS 'PF9006'.
    SET TITLEBAR  'T9003'.

  ENDIF.

  PERFORM get_description_field_monitor.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_9009 OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE status_9009 OUTPUT.
  SET PF-STATUS 'PF9009'.
  SET TITLEBAR 'T9005'.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_9005 OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE status_9005 OUTPUT.

  PERFORM get_description_field_monitor.

ENDMODULE.
