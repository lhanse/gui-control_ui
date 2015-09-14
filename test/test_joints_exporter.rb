require 'orocos'
require 'control_ui/joints_exporter'

Orocos.initialize

Orocos.load_typekit_for "/base/samples/Joints"

app=Qt::Application.new 0, []

class CTRL_EMU
    def getJoints
        return Types::Base::Samples::Joints.new
    end
    def setJointState(b)
        puts Orocos::TaskConfigurations.typelib_to_yaml_value(b).to_yaml
    end
end
crtl_emu = CTRL_EMU.new
widget = JointsExporter.new(crtl_emu)
widget.show

app.exec

