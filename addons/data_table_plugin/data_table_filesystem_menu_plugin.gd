@tool
class_name DataTableFilesystemMenuPlugin
extends EditorContextMenuPlugin


@warning_ignore_start("unsafe_cast")
@warning_ignore_start("return_value_discarded")
@warning_ignore_start("unsafe_call_argument")


# plugin config
var plugin_cfg: ConfigFile = ConfigFile.new()

# overlay button
var overlay: Button


func _popup_menu(paths: PackedStringArray) -> void:
	if paths.size() == 1:
		var data_table: DataTable = load(paths[0]) as DataTable
		if data_table:
			add_context_menu_item("Export as CSV", _on_export_as_csv_clicked)
			add_context_menu_item("Import from CSV", _on_import_from_csv_clicked)


#region private
# 导出到csv
func _on_export_as_csv_clicked(paths: Array[String]) -> void:
	var cfg_load_err: Error = plugin_cfg.load("res://addons/data_table_plugin/plugin.cfg")
	if cfg_load_err != Error.OK:
		push_error("plugin_cfg load error [%d]" % [ cfg_load_err ])
	if paths.size() == 1:
		var path: String = paths[0]
		var data_table: DataTable = load(path) as DataTable
		if data_table:
			var table_row_template_object: TableRowBase = null
			if data_table.table_row_script == null:
				push_warning("DataTableFilesystemMenuPlugin: Export %s, has no set table_row_script" % [path])
				return
			table_row_template_object = data_table.table_row_script.new()
			var row_base: TableRowBase = data_table.table_row_script.new()
			var property_list: Array[Dictionary] = row_base.get_script_variable_property_list()
			
			var lines: Array[PackedStringArray] = []
			# 表头
			lines.push_back(PackedStringArray())
			lines[0].push_back("---")
			for property: Dictionary in property_list:
				lines[0].push_back(property["name"])
			# 表内容
			var value: String
			var index: int = 1
			for row_name: String in data_table.datas:
				lines.push_back(PackedStringArray())
				lines[index].push_back(row_name)
				for property: Dictionary in property_list:
					value = var_to_str((data_table.datas[row_name] as Dictionary).get(property["name"], table_row_template_object.get(property["name"])))
					#print(value)
					lines[index].push_back(value)
				index += 1
			# 保存到文件
			var file_store_func: Callable = func (p_path: String) -> void:
				var file: FileAccess = FileAccess.open(p_path, FileAccess.WRITE)
				if file:
					var has_error: bool = false
					for line: PackedStringArray in lines:
						if !file.store_csv_line(line, ","):
							has_error = true
							push_error("store_csv_line %s failed!" % [ line ])
					if !has_error:
						print_rich("[color=green]Export [%s] to [%s] success![/color]" % [ data_table.resource_path, p_path ])
				else:
					push_error("DataTableFilesystemMenuPlugin: FileAccess.open error [%d]" % [ FileAccess.get_open_error() ])
			#print(content)
			var file_base_dir: String = path.get_base_dir()
			var file_name: String = path.get_file().get_basename()
			var title: String = "Export '%s' as CSV..." % [ file_name ]
			var target_csv_name: String = "%s.csv" % [ file_name ]
			# 使用原生对话框
			if plugin_cfg.get_value("custom", "use_native_dialog"):
				# 全屏按钮遮罩
				_add_full_screen_overlay_button()
				# 操作系统弹窗回调
				var display_server_callback: Callable = func (status: bool, files: Array[String], _index: int) -> void:
					_remove_full_screen_overlay_button()
					if status == true:
						file_store_func.call(files[0])
				# 弹出操作系统弹窗 (godot弹出的操作系统原生对话框, gdscript甚至godot源码都无权访问它 因此我们点击godot后 对话框会被顶下去 但我们无法设置他前置.. 当然你也可以在plugin.cfg里设置use_native_dialog=false) 
				var dialog_err: Error = DisplayServer.file_dialog_show(title, file_base_dir, target_csv_name, false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, ["*.csv"], display_server_callback)
				if dialog_err != Error.OK:
					push_error("DataTableFilesystemMenuPlugin: _on_export_as_csv_clicked file_dialog_show error [%d]" % [ dialog_err ])
			# 使用EditorFileDialog
			else:
				# 弹出EditorFileDialog
				var file_dialog: EditorFileDialog = EditorFileDialog.new()
				file_dialog.title = title
				file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
				file_dialog.access = FileDialog.ACCESS_FILESYSTEM
				file_dialog.add_filter("*.csv", "CSV")
				file_dialog.current_dir = ProjectSettings.globalize_path(file_base_dir)
				file_dialog.current_file = target_csv_name
				file_dialog.file_selected.connect(file_store_func)
				EditorInterface.get_base_control().add_child(file_dialog)
				file_dialog.popup_centered()
			row_base.free()


# 从csv导入
func _on_import_from_csv_clicked(paths: Array[String]) -> void:
	var cfg_load_err: Error = plugin_cfg.load("res://addons/data_table_plugin/plugin.cfg")
	if cfg_load_err != Error.OK:
		push_error("plugin_cfg load error [%d]" % [ cfg_load_err ])
	if paths.size() == 1:
		var path: String = paths[0]
		var data_table: DataTable = ResourceLoader.load(path) as DataTable
		if !data_table:
			return
		var file_base_dir: String = path.get_base_dir()
		var file_name: String = path.get_file().get_basename()
		var title: String = "Import '%s' from CSV..." % [ file_name ]
		var target_csv_name: String = "%s.csv" % [ file_name ]
		# 从文件导入
		var file_import_func: Callable = func (p_path: String) -> void:
			var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
			if file:
				var datas: Dictionary = {} # { "RowName": { "PropertyName": Variant, ... }, ... }
				# header
				var header: PackedStringArray = file.get_csv_line(",")
				var header_size: int = header.size()
				# rows
				while !file.eof_reached():
					var row: PackedStringArray = file.get_csv_line(",")
					var row_size: int = row.size()
					if row_size > 0 && !row[0].is_empty():
						if !datas.has(row[0]):
							datas[row[0]] = {}
							for i: int in range(1, header_size if header_size > row_size else row_size):
								#print(row[i], " -> ", str_to_var(row[i]))
								datas[row[0]][header[i]] = str_to_var(row[i])
						else:
							push_warning("DataTableFilesystemMenuPlugin: import from csv has row[%s] more than once!" % [ row[0] ])
				#print(datas)
				# 导入
				data_table.datas = {}
				var table_row_template_object: TableRowBase = null
				if data_table.table_row_script != null:
					table_row_template_object = data_table.table_row_script.new()
				if table_row_template_object:
					var property_list: Array[Dictionary] = table_row_template_object.get_script_variable_property_list()
					for row_name: String in datas.keys():
						data_table.datas[row_name] = {}
						for property: Dictionary in property_list:
							data_table.datas[row_name][property["name"]] = (datas[row_name] as Dictionary).get(property["name"], table_row_template_object.get(property["name"]))
					table_row_template_object.free()
				#print("------------------------")
				#print(data_table.datas)
				data_table.save()
				print_rich("[color=green]Import [%s] from [%s] success![/color]" % [ data_table.resource_path, p_path ])
				EditorInterface.edit_resource(data_table)
			else:
				push_error("DataTableFilesystemMenuPlugin: FileAccess.open error [%d]" % [ FileAccess.get_open_error() ])
		# 使用原生对话框
		if plugin_cfg.get_value("custom", "use_native_dialog"):
			# 全屏按钮遮罩
			_add_full_screen_overlay_button()
			# 操作系统弹窗回调
			var display_server_callback: Callable = func (status: bool, files: Array[String], _index: int) -> void:
				_remove_full_screen_overlay_button()
				if status == true:
					file_import_func.call(files[0])
			var dialog_err: Error = DisplayServer.file_dialog_show(title, file_base_dir, target_csv_name, false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.csv"], display_server_callback)
			if dialog_err != Error.OK:
				push_error("DataTableFilesystemMenuPlugin: _on_import_from_csv_clicked file_dialog_show error [%d]" % [ dialog_err ])
		# 使用EditorFileDialog
		else:
			# 弹出EditorFileDialog
			var file_dialog: EditorFileDialog = EditorFileDialog.new()
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			file_dialog.add_filter("*.csv", "CSV")
			file_dialog.current_dir = ProjectSettings.globalize_path(file_base_dir)
			file_dialog.current_file = target_csv_name
			file_dialog.file_selected.connect(file_import_func)
			EditorInterface.get_base_control().add_child(file_dialog)
			file_dialog.popup_centered()
			file_dialog.title = title


# 增加全屏遮罩按钮
func _add_full_screen_overlay_button() -> void:
	if overlay == null:
		overlay = Button.new()
		overlay.anchor_left = 0.0
		overlay.anchor_top = 0.0
		overlay.anchor_right = 1.0
		overlay.anchor_bottom = 1.0
		overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	EditorInterface.get_base_control().add_child(overlay)
	EditorInterface.get_base_control().modulate = Color(1.0, 1.0, 1.0, 0.4)


# 移除全屏遮罩按钮
func _remove_full_screen_overlay_button() -> void:
	if overlay:
		EditorInterface.get_base_control().remove_child(overlay)
		overlay.queue_free()
	EditorInterface.get_base_control().modulate = Color(1.0, 1.0, 1.0, 1.0)
#endregion
