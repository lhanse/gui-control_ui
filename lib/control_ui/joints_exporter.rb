require 'Qt'

Orocos.load_typekit_for "/base/samples/Joints"

class JointsExporter < Qt::Widget
 
	def initialize(ctrl_gui)
		super(nil)
		hlayout = Qt::HBoxLayout.new
		
		file_dlg = Qt::FileDialog.new		
		
		impt_btn = Qt::PushButton.new("Import Joints Configuration")
		impt_btn.connect(SIGNAL('clicked()')) do
			file_dlg.setAcceptMode(Qt::FileDialog::AcceptOpen)
			if file_dlg.exec then
				file_name = file_dlg.selectedFiles()[0]
				if File.file?(file_name) then
				    f = File.new(file_name,"r")
				    joint_sample = Types::Base::Samples::Joints.new
				    begin
				        imp_map = YAML::load(f.read)				
				        Orocos::TaskConfigurations.typelib_from_yaml_value joint_sample, imp_map
                    rescue IOError,Psych::SyntaxError,Typelib::UnknownConversionRequested => errName
                       puts "Import failed: " + errName.to_s
                    else
                        ctrl_gui.setJointState(joint_sample)
                    end
                    f.close
                end
			end	
		end
		
		hlayout.addWidget(impt_btn)
		
		expt_btn = Qt::PushButton.new("Export Joints Configuration")
		expt_btn.connect(SIGNAL('clicked()')) do
		    file_dlg.setAcceptMode(Qt::FileDialog::AcceptSave)
			if file_dlg.exec then
				file_name = file_dlg.selectedFiles()[0]
			
				sample = ctrl_gui.getJoints()
				exp_yaml = Orocos::TaskConfigurations.typelib_to_yaml_value(sample).to_yaml
				f = File.new(file_name,"w")
				f.write(exp_yaml)
				f.close
			end
		end
		
		hlayout.addWidget(expt_btn)

		setLayout(hlayout)
	end
end
