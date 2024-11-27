*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0001C01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Class LCX_XLSX_UPLOADER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
CLASS lcx_xlsx_uploader DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    DATA local_text TYPE string.
    METHODS constructor IMPORTING text TYPE string.

ENDCLASS.


*&---------------------------------------------------------------------*
*& Class LCX_XLSX_UPLOADER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
CLASS lcx_xlsx_uploader IMPLEMENTATION.


*&---------------------------------------------------------------------*
*& Class CONSTRUCTOR
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
  METHOD constructor.
    super->constructor( ).
    local_text = text.
  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
*& Class LCL_XLSX_UPLOADER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
CLASS lcl_xlsx_uploader DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS handle_onf4 FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING e_fieldname
                es_row_no
                er_event_data.


    CLASS-METHODS validate_structure
      CHANGING checked_structure_name TYPE string
      RAISING  lcx_xlsx_uploader.

    METHODS constructor
      IMPORTING filefullpath   TYPE string
                structure_name TYPE string
                sheet_id       TYPE i
      RAISING   lcx_xlsx_uploader.

    METHODS import
      EXPORTING return TYPE data
      RAISING   lcx_xlsx_uploader.

    METHODS get_tablecontent
      EXPORTING tablecontent TYPE ANY TABLE
      RAISING   lcx_xlsx_uploader.

    METHODS get_table_type
      RETURNING VALUE(return) TYPE REF TO cl_abap_tabledescr.

  PROTECTED SECTION.
    METHODS extract_data_from_excel
      RAISING lcx_xlsx_uploader.

  PRIVATE SECTION.

    DATA: filefullpath   TYPE string,
          structure_name TYPE string,
          sheet_id       TYPE i,
          tableinfo      TYPE tadir,
          tablestructure TYPE REF TO cl_abap_structdescr,
          tabletype      TYPE REF TO cl_abap_tabledescr,
          tabledata      TYPE REF TO data.

ENDCLASS.


*&---------------------------------------------------------------------*
*& Class LCL_XLSX_UPLOADER
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
CLASS lcl_xlsx_uploader IMPLEMENTATION.

  METHOD handle_onf4.

    BREAK-POINT.

    PERFORM on_f4.


  ENDMETHOD.


  METHOD constructor.

    IF filefullpath IS INITIAL OR structure_name IS INITIAL.
      RAISE EXCEPTION TYPE lcx_xlsx_uploader
        EXPORTING
          text = |O arquivo { filefullpath } e o nome da estrutura { structure_name } devem ser preenchidos.|.
    ENDIF.

    me->filefullpath   = filefullpath.
    me->structure_name = structure_name.
    me->sheet_id       = sheet_id.

    lcl_xlsx_uploader=>validate_structure( CHANGING checked_structure_name = me->structure_name ).

    me->tablestructure ?= cl_abap_typedescr=>describe_by_name( me->structure_name  ).

    IF NOT me->tablestructure IS BOUND.
      RAISE EXCEPTION TYPE lcx_xlsx_uploader
        EXPORTING
          text = |Ocorreu uma exceção na análise da estrutura: { structure_name } |.
    ENDIF.

    TRY.
        me->tabletype = cl_abap_tabledescr=>create( p_line_type = me->tablestructure ).
      CATCH cx_sy_table_creation INTO DATA(tabletypeexception).
        RAISE EXCEPTION TYPE lcx_xlsx_uploader
          EXPORTING
            text = |Ocorreu uma exceção na criação do tipo de dados da estrurura: { structure_name } |.
    ENDTRY.

    CREATE DATA tabledata TYPE HANDLE me->tabletype.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Class IMPORT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
  METHOD import.

    me->extract_data_from_excel( ).

    FIELD-SYMBOLS <tabledata> TYPE STANDARD TABLE.
    ASSIGN me->tabledata->* TO <tabledata>.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Class GET_TABLECONTENT
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
  METHOD get_tablecontent.

    FIELD-SYMBOLS <tabledata> TYPE STANDARD TABLE.
    ASSIGN me->tabledata->* TO <tabledata>.

    tablecontent = <tabledata>.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Class GET_TABLE_TYPE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
  METHOD get_table_type.
    return = me->tabletype.
  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Class VALIDATE_STRUCTURE
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
  METHOD validate_structure.

    SELECT SINGLE * FROM tadir INTO @DATA(tableinfo) WHERE obj_name = @checked_structure_name AND object = 'TABL'. "#EC CI_GENBUFF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE lcx_xlsx_uploader
        EXPORTING
          text = |Estrutura { checked_structure_name } não existe.|.
    ENDIF.

    TRY.
        checked_structure_name =
           cl_abap_dyn_prg=>check_table_or_view_name_str( val               = checked_structure_name
                                                          packages          = CONV #( tableinfo-devclass )
                                                          incl_sub_packages = abap_true ).
      CATCH cx_abap_not_a_table
            cx_abap_not_in_package.
        RETURN.
    ENDTRY.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Class EXTRACT_DATA_FROM_EXCEL
*&---------------------------------------------------------------------*
*& Text - First Big Project Challenge
*&---------------------------------------------------------------------*
  METHOD extract_data_from_excel.

    FIELD-SYMBOLS <exceldata> TYPE STANDARD TABLE.
    ASSIGN me->tabledata->* TO <exceldata>.

    DATA(xlsxhandler) = cl_ehfnd_xlsx=>get_instance( ).
    CHECK NOT xlsxhandler IS INITIAL.

    TRY.
        DATA(xstring_excel) = cl_openxml_helper=>load_local_file( me->filefullpath ).
      CATCH cx_openxml_not_found INTO DATA(openxml_not_found).
        RETURN.
    ENDTRY.

    TRY.
        DATA(xlsxdocument) = xlsxhandler->load_doc( iv_file_data = xstring_excel ).
      CATCH cx_openxml_format INTO DATA(openxml_format).
        RETURN.
      CATCH cx_openxml_not_allowed INTO DATA(openxml_not_allowed).
        RETURN.
      CATCH cx_dynamic_check INTO DATA(dynamic_check).
        RETURN.
    ENDTRY.

    TRY.
        DATA(sheet) = xlsxdocument->get_sheet_by_id( iv_sheet_id = me->sheet_id ).
      CATCH cx_openxml_format  INTO openxml_format.
        RAISE EXCEPTION TYPE lcx_xlsx_uploader
          EXPORTING
            text = |Erro ao estrair os dados do planilha de excel: CX_OPENXML_FORMAT |.
      CATCH cx_openxml_not_found  INTO openxml_not_found.
        RAISE EXCEPTION TYPE lcx_xlsx_uploader
          EXPORTING
            text = |Erro ao estrair os dados do planilha de excel: OPENXML_NOT_FOUND |.
      CATCH cx_dynamic_check  INTO dynamic_check.
        RAISE EXCEPTION TYPE lcx_xlsx_uploader
          EXPORTING
            text = |Erro ao estrair os dados do planilha de excel: CX_DYNAMIC_CHECK |.
    ENDTRY.

    CHECK NOT sheet IS INITIAL.

    DATA(columncount) = sheet->get_last_column_number_in_row( 1 ).

    DATA column TYPE i VALUE 1.

    DATA(tablecomponents) = me->tablestructure->get_components( ).

    DATA invalidcolumn TYPE string.
    TYPES: BEGIN OF columninfo,
             column     TYPE i,
             columnname TYPE string,
           END OF columninfo.

    TYPES columnsinfo TYPE STANDARD TABLE OF columninfo WITH EMPTY KEY.

    DATA columnfromfile TYPE columnsinfo.

    DO columncount TIMES.

      DATA(cellvalue) = sheet->get_cell_content( iv_row    = 1
                                                 iv_column = column ).

      APPEND INITIAL LINE TO columnfromfile ASSIGNING FIELD-SYMBOL(<columnfromfile>).
      <columnfromfile>-column     = column.
      <columnfromfile>-columnname = cellvalue.

      IF line_exists( tablecomponents[ name = cellvalue ] ).
        DELETE tablecomponents WHERE name = cellvalue.
      ELSE.
        invalidcolumn = invalidcolumn && |,{ cellvalue }|.
      ENDIF.
      column = column + 1.

    ENDDO.

    DATA missingcolumns TYPE string.

    LOOP AT tablecomponents REFERENCE INTO DATA(currentcomponent).
      missingcolumns = missingcolumns && |, { currentcomponent->*-name }|.
    ENDLOOP.

    IF NOT invalidcolumn IS INITIAL.
      RAISE EXCEPTION TYPE lcx_xlsx_uploader
        EXPORTING
          text = |Coluna inválida encontrada: { invalidcolumn } |.
    ENDIF.

    tablecomponents = me->tablestructure->get_components( ).
    DATA(rowcount) = sheet->get_last_row_number( ).
    DATA currentrow TYPE i VALUE 2.

    WHILE currentrow <= rowcount.

      APPEND INITIAL LINE TO <exceldata> ASSIGNING FIELD-SYMBOL(<currentrow>).

      LOOP AT columnfromfile REFERENCE INTO DATA(currentcolumn).

        cellvalue = sheet->get_cell_content( iv_row    = currentrow
                                             iv_column = currentcolumn->*-column ).

        ASSIGN COMPONENT currentcolumn->*-columnname OF STRUCTURE <currentrow> TO FIELD-SYMBOL(<cellvalue>).

        <cellvalue> = cellvalue.

      ENDLOOP.

      currentrow = currentrow + 1.

    ENDWHILE.

  ENDMETHOD.

ENDCLASS.
