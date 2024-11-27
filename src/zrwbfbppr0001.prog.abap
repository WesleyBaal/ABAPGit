*- SAP------------------------------------------------------------SAP -*
*-        *** Programa de Carga - Peso bruto do material  ***         -*
*- SAP------------------------------------------------------------SAP -*
************************************************************************
* Projeto: First Big Project Challenge - ABAP
* Modulo / Componente:
*
* Report: ZRWBFBPPR0001
* Descrição: Programa de Carga - Peso bruto do material
*
* Modo Execução: [] Background * [X] Online
*
************************************************************************
* Autor: Wesley Baal                                    Data: 11/10/2023
*
************************************************************************
* Modificações:
*
************************************************************************
REPORT zrwbfbppr0001.

INCLUDE zrwbfbppr0001top.
INCLUDE zrwbfbppr0001c01.
INCLUDE zrwbfbppr0001f01.
INCLUDE zrwbfbppr0001o01.
INCLUDE zrwbfbppr0001i01.

START-OF-SELECTION.

  PERFORM execute.

END-OF-SELECTION.

  IF uploaded_data IS NOT INITIAL.
    CALL SCREEN 9001.
  ELSE.
    MESSAGE s001(zrwbfbpmc0001) DISPLAY LIKE 'W'. "Nenhum arquivo de upload foi fornecido!
  ENDIF.
