*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0001TOP
*&---------------------------------------------------------------------*

CONSTANTS: c_path(3) VALUE 'C:\'.

FIELD-SYMBOLS <output_data> TYPE STANDARD TABLE.

DATA: ok_code         TYPE sy-ucomm,
      sort            TYPE lvc_t_sort,
      headdata        TYPE bapimathead,
      fieldcat        TYPE lvc_t_fcat,
      exclude_toolbar TYPE ui_functions,
      dir             TYPE string,
      check           TYPE char10,

      uploaded_data   TYPE TABLE OF zrwbfbps0001,
      output_data     TYPE TABLE OF zrwbfbps0001,
      unitsofmeasure  TYPE TABLE OF bapi_marm,
      unitsofmeasurex TYPE TABLE OF bapi_marmx,

      tabledata       TYPE REF TO data,
      alv_grid        TYPE REF TO cl_gui_alv_grid.

SELECTION-SCREEN BEGIN OF SCREEN 110 AS SUBSCREEN.

  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001. "Alterar peso bruto do material.
    PARAMETERS: p_load LIKE rlgrap-filename.
  SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN END OF SCREEN 110.

SELECTION-SCREEN BEGIN OF SCREEN 120 AS SUBSCREEN.

  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
    PARAMETERS: p_log LIKE rlgrap-filename DEFAULT c_path.
  SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF SCREEN 120.

SELECTION-SCREEN BEGIN OF TABBED BLOCK tab FOR 23 LINES.

  SELECTION-SCREEN TAB (20) tab1 USER-COMMAND comm1 DEFAULT SCREEN 110.
  SELECTION-SCREEN TAB (20) tab2 USER-COMMAND comm2 DEFAULT SCREEN 120.

SELECTION-SCREEN END OF BLOCK tab.

INITIALIZATION.

  tab1 = 'Arquivo upload'.
  tab2 = 'Diretório de log'.

  tab-activetab = 'COMM1'.
  tab-dynnr     = 110.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_load.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask      = '*.txt*.*.xlsx* '
    CHANGING
      file_name = p_load.

AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_log.

  dir = p_log.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Selecione diretório para gravar arquivos de log'
      initial_folder       = dir
    CHANGING
      selected_folder      = dir
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  p_log = dir.
