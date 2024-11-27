*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0002TOP
*&---------------------------------------------------------------------*

CONTROLS: container TYPE TABSTRIP.

DATA: ok_code                 TYPE syucomm,
      control_screen          TYPE char15,
      control_subscreen       TYPE sy-dynnr VALUE '9003',
      control_alv             TYPE sy-dynnr,
      control_parameter_id    TYPE char15,
      screen_fields           TYPE zrwbfbpt0001,
      customer_supplier       TYPE lfa1,
      variant_transport       TYPE disvariant,
      variant_item            TYPE disvariant,
      fieldcat_transport      TYPE lvc_t_fcat,
      fieldcat_item           TYPE lvc_t_fcat,
      fieldcat_historic       TYPE lvc_t_fcat,
      exclude_toolbar         TYPE ui_functions,
      picking_task_data       TYPE zrwbfbps0003,
      shipment_request_data   TYPE zrwbfbps0003,
      line                    TYPE zrwbfbps0004,

      id_transport            TYPE TABLE OF zrwbfbpt0001,
      item_data               TYPE TABLE OF zrwbfbpt0002,
      output_transport        TYPE TABLE OF zrwbfbps0004,
      output_item             TYPE TABLE OF zrwbfbps0004,
      selected_data           TYPE TABLE OF zrwbfbps0004,
      output_historic         TYPE TABLE OF zrwbfbps0005,

      alv_grid_transport      TYPE REF TO cl_gui_alv_grid,
      alv_grid_item           TYPE REF TO cl_gui_alv_grid,
      alv_grid_historic       TYPE REF TO cl_gui_alv_grid,
      alv_grid                TYPE REF TO cl_gui_alv_grid,
      docking_container       TYPE REF TO cl_gui_docking_container,
      alv_container_transport TYPE REF TO cl_gui_custom_container,
      alv_container_item      TYPE REF TO cl_gui_custom_container,
      alv_container           TYPE REF TO cl_gui_custom_container.
