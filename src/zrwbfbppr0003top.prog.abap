*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0003TOP
*&---------------------------------------------------------------------*

CONTROLS: container TYPE TABSTRIP.

TABLES: zrwbfbpt0001.

DATA: ok_code              TYPE syucomm,
      control_screen       TYPE char15,
      variant_header       TYPE disvariant,
      variant_item         TYPE disvariant,
      fieldcat_header      TYPE lvc_t_fcat,
      fieldcat_item        TYPE lvc_t_fcat,
      fieldcat_historic    TYPE lvc_t_fcat,
      layout_item          TYPE lvc_s_layo,
      layout_header        TYPE lvc_s_layo,
      shipment_request_id  TYPE zrwbfbpt0001-id,
      exclude_toolbar      TYPE ui_functions,
      shipment_request     TYPE zrwbfbps0003,
      check_status         TYPE char10,
      line                 TYPE zrwbfbps0004,

      output_item          TYPE TABLE OF zrwbfbps0004,
      header_data          TYPE TABLE OF zrwbfbpt0001,
      output_header        TYPE TABLE OF zrwbfbps0008,
      output_historic      TYPE TABLE OF zrwbfbps0005,

      alv_grid_header      TYPE REF TO cl_gui_alv_grid,
      alv_grid_item        TYPE REF TO cl_gui_alv_grid,
      alv_grid_historic    TYPE REF TO cl_gui_alv_grid,
      splitter_container   TYPE REF TO cl_gui_splitter_container,
      custom_container     TYPE REF TO cl_gui_custom_container,
      container_alv_header TYPE REF TO cl_gui_container,
      container_alv_item   TYPE REF TO cl_gui_container.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_ship  FOR zrwbfbpt0001-id ,
                  s_stat  FOR zrwbfbpt0001-status,
                  s_cust  FOR zrwbfbpt0001-customer,
                  s_plant FOR zrwbfbpt0001-plant,
                  s_comp  FOR zrwbfbpt0001-shipping_company_code,
                  s_name  FOR zrwbfbpt0001-driver_name,
                  s_tran  FOR zrwbfbpt0001-transport_type,
                  s_veih  FOR zrwbfbpt0001-vehicle_type,
                  s_plate FOR zrwbfbpt0001-plate_id,
                  s_date  FOR zrwbfbpt0001-departure_date.

SELECTION-SCREEN END OF BLOCK b1.
