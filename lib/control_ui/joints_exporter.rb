require 'Qt'

Orocos.load_typekit "waypoint_provider"

class JointsExporter < Qt::Widget
 
	def initialize(ctrl_gui)
		super(nil)
		vlayout = Qt::VBoxLayout.new
		
		btnlayout = Qt::HBoxLayout.new
		file_dlg = Qt::FileDialog.new
		
		tabs_widget = Qt::TabWidget.new
		tmodel = Orocos::task_model_from_name "waypoint_provider::JointWaypointProvider"
		tcfg = Orocos::TaskConfigurations.new(tmodel)
		
		def updateTabMenu(tabs_widget,tcfg,ctrl_gui)
		    ind = tabs_widget.currentIndex()
		    tabs_widget.clear
		    tcfg.sections.each do |name,cfgmap|
                radlayout = Qt::HBoxLayout.new
                tabwid = Qt::Widget.new
                tabwid.setLayout(radlayout)
                counter = 1
                if cfgmap["waypoints"] then
                    cfgmap["waypoints"].each do |joint_sample|
                        radbtn = Qt::RadioButton.new("State " + counter.to_s)
                        counter += 1
                        radbtn.connect(SIGNAL('clicked()')) do
                            if radbtn.isChecked() then
                                ctrl_gui.setReference(joint_sample)
                            end
                        end
                        radlayout.addWidget(radbtn)                        
                    end
                    addwaybtn = Qt::PushButton.new("Add a Waypoint")
                    addwaybtn.connect(SIGNAL('clicked()')) do
                        joints = ctrl_gui.getJoints()
                        cfgmap["accuracies"].push({"data"=>Array.new(joints.elements.size,0.01)})
                        cfgmap["waypoints"].push(joints)
                        updateTabMenu(tabs_widget,tcfg,ctrl_gui)
                    end
                    radlayout.addWidget(addwaybtn)
                    tabs_widget.addTab(tabwid,name)
                end
                tabs_widget.setCurrentIndex(ind)
            end
            inplayout = Qt::HBoxLayout.new
            adddocwid = Qt::Widget.new
            textbox = Qt::LineEdit.new
            inplayout.addWidget(textbox)
            doc_btn = Qt::PushButton.new("Create Document")
            doc_btn.connect(SIGNAL('clicked()')) do
                new_conf = {"accuracies"=>[],"waypoints"=>[]}
                tcfg.add(textbox.text,new_conf)
                updateTabMenu(tabs_widget,tcfg,ctrl_gui)
            end
            inplayout.addWidget(doc_btn)
            adddocwid.setLayout(inplayout)
		    tabs_widget.addTab(adddocwid,"Add a Document")			
		end
		updateTabMenu(tabs_widget,tcfg,ctrl_gui)
			            		
		
		impt_btn = Qt::PushButton.new("Import Joints Configuration")
		impt_btn.connect(SIGNAL('clicked()')) do
			file_dlg.setAcceptMode(Qt::FileDialog::AcceptOpen)
			if file_dlg.exec and file_dlg.result == Qt::Dialog::Accepted then
				file_name = file_dlg.selectedFiles()[0]
				if File.file?(file_name) then
				    begin
				        tcfg.load_from_yaml(file_name)
				        updateTabMenu(tabs_widget,tcfg,ctrl_gui)
                    rescue IOError,Psych::SyntaxError => errName
                        puts "Import failed: " + errName.to_s
                    end
                end
			end	
		end		
		btnlayout.addWidget(impt_btn)
		
		expt_btn = Qt::PushButton.new("Export Joints Configuration")
		expt_btn.connect(SIGNAL('clicked()')) do
		    file_dlg.setAcceptMode(Qt::FileDialog::AcceptSave)
			if file_dlg.exec and file_dlg.result == Qt::Dialog::Accepted then
				file_name = file_dlg.selectedFiles()[0]
				
				if File.exists?(file_name) then
					File.delete(file_name)
			    end

				tcfg.sections.each do |name,cfgmap|
				    expcontext = Orocos::RubyTasks::TaskContext.from_orogen_model("exporter_context",tmodel)
				    #expcontext.each_property = {}.each
				    tcfg.apply(expcontext,[name],true)
			        if name != "default" and tcfg["default"] then
				        expcontext.properties.each do |pname,pval|
				            if tcfg.sections["default"][pname] == pval then
				                
				            end
				        end
				    end
				    #puts expcontext.properties
			        tcfg.save(expcontext,file_name,name)
			    end
			end
		end
		btnlayout.addWidget(expt_btn)
		
		
		
		tgl_btn = Qt::PushButton.new("Hide Tab Widget")
		tgl_btn.connect(SIGNAL('clicked()')) do
		    tabs_widget.setVisible(tabs_widget.isHidden)
		end
		btnlayout.addWidget(tgl_btn)
		
		vlayout.addWidget(tabs_widget)
		vlayout.addItem(btnlayout)
		setLayout(vlayout)
	end
end
