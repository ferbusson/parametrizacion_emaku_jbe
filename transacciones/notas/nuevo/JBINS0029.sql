--JBINS0029
insert into 
	documentos_externos_nota_contable(
		ndocumento,
		orden,
		ex_documento)
values('?',current_value('libro_auxiliar_orden_seq'),'?');