*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0003O01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module BUILD_ALV
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

  PERFORM split_container.

  IF alv_grid_header IS INITIAL.

    alv_grid_header = NEW #( i_parent = container_alv_header ).

    layout_header = VALUE lvc_s_layo( grid_title = 'Solicitações de transporte'
                                      cwidth_opt = abap_false
                                      zebra      = abap_true
                                      sel_mode   = 'B' ).

    PERFORM header_fieldcatalog USING    header_data
                                CHANGING fieldcat_header.

    SET HANDLER handle_event=>handle_button_click   FOR alv_grid_header.
    SET HANDLER handle_event=>handle_hotspot_click  FOR alv_grid_header.

    alv_grid_header->set_table_for_first_display(
     EXPORTING
       i_save               = 'A'
       is_layout            = layout_header
       is_variant           = variant_header
       it_toolbar_excluding = exclude_toolbar
     CHANGING
       it_outtab            = output_header
       it_fieldcatalog      = fieldcat_header ).

  ELSE.

    SET HANDLER handle_event=>handle_button_click   FOR alv_grid_header.

    alv_grid_header->set_frontend_layout( is_layout = layout_header ).

  ENDIF.

  IF alv_grid_item IS INITIAL.

    alv_grid_item = NEW #( i_parent = container_alv_item ).

    layout_item = VALUE lvc_s_layo( grid_title = |Itens da solicitação de transporte { shipment_request_id }|
                                    zebra      = abap_true
                                    sel_mode   = 'A' ).

    SET HANDLER handle_event=>handle_toolbar_item FOR alv_grid_item.
    SET HANDLER handle_event=>handle_user_command FOR alv_grid_item.
    SET HANDLER handle_event=>handle_button_click FOR alv_grid_item.

    PERFORM item_fieldcatalog .

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

    alv_grid_item->refresh_table_display( ).
    alv_grid_item->set_frontend_layout( is_layout = layout_item ).

  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module BUILD_ALV_HISTORIC OUTPUT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
MODULE build_alv_historic OUTPUT.

  IF alv_grid_historic IS INITIAL.

    DATA(docking_container) = NEW cl_gui_docking_container( extension = '2500' ).
    alv_grid_historic = NEW cl_gui_alv_grid( i_parent = docking_container ).

    DATA(layout_historic) = VALUE lvc_s_layo( grid_title =  |Remessa: { line-delivery } Item: { line-item } - { line-material }|
                                              zebra      = abap_true
                                              no_toolbar = abap_true
                                              info_fname = 'COLOR').

    PERFORM item_fieldcatalog.

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
*&
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.

  SET PF-STATUS 'PF9002'.
  SET TITLEBAR 'T9002'.

ENDMODULE.
