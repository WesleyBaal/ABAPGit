CLASS zrwbfbpcl_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS upload
      IMPORTING file_data     TYPE localfile
      RETURNING VALUE(return) TYPE zrwbfbps0001_tab.

    CLASS-METHODS convert_output_by_convexit
      IMPORTING convexit      TYPE convexit
                value         TYPE any
      RETURNING VALUE(return) TYPE text1000.

    CLASS-METHODS get_bapiret2
      IMPORTING id            TYPE sy-msgid
                number        TYPE sy-msgno
                type          TYPE sy-msgty
                var1          TYPE sy-msgv1 OPTIONAL
                var2          TYPE sy-msgv2 OPTIONAL
                var3          TYPE sy-msgv3 OPTIONAL
                var4          TYPE sy-msgv4 OPTIONAL
      RETURNING VALUE(return) TYPE bapiret2.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS zrwbfbpcl_utilities IMPLEMENTATION.

  METHOD get_bapiret2.

    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = type
        cl     = id
        number = number
        par1   = var1
        par2   = var2
        par3   = var3
        par4   = var4
      IMPORTING
        return = return.

  ENDMETHOD.


  METHOD upload.

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = CONV string( file_data )
        filetype                = 'ASC'
        has_field_separator     = 'X'
        replacement             = ' '
      CHANGING
        data_tab                = return
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

  ENDMETHOD.


  METHOD convert_output_by_convexit.

    DATA: function_name TYPE funcname.

    function_name = |CONVERSION_EXIT_{ convexit }_OUTPUT|.

    CALL FUNCTION function_name
      EXPORTING
        input  = value
      IMPORTING
        output = return.

    CONDENSE return.

  ENDMETHOD.

ENDCLASS.
