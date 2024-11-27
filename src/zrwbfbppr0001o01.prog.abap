*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0001O01
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
*& Module  build_alv
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*----------------------------------------------------------------------*
MODULE build_alv OUTPUT.

  DATA: lt_f4 TYPE lvc_t_f4 WITH HEADER LINE.

  exclude_toolbar = VALUE #( ( '&DETAIL'     )
                             ( '&&SEP00'     )
                             ( '&SORT_ASC'   )
                             ( '&SORT_DSC'   )
                             ( '&PRINT_BACK' )
                             ( '&&SEP01'     )
                             ( '&&SEP02'     )
                             ( '&&SEP03'     )
                             ( '&MB_FILTER'  )
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

    lt_f4-fieldname = 'SIZES'.
    lt_f4-register = 'X'.

    INSERT TABLE lt_f4.

    alv_grid = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen ).

    PERFORM fieldcatalog.

    CALL METHOD alv_grid->register_f4_for_fields
      EXPORTING
        it_f4 = lt_f4[].

    SET HANDLER lcl_xlsx_uploader=>handle_onf4 FOR alv_grid.

    DATA(layout) = VALUE lvc_s_layo( grid_title = 'Dados do Material'
                                     cwidth_opt = abap_true
                                     zebra      = abap_true
                                     sel_mode   = 'A' ).


    alv_grid->set_table_for_first_display(
      EXPORTING
        i_save                = 'A'
        is_layout             = layout
         it_toolbar_excluding = exclude_toolbar
      CHANGING
        it_outtab             = output_data
        it_fieldcatalog       = fieldcat  ).

  ELSE.
    alv_grid->set_frontend_layout( is_layout = layout ).
    alv_grid->refresh_table_display( ).
  ENDIF.

ENDMODULE.
