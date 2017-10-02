from abaqus import *
from abaqusConstants import *
import odbAccess
from math import floor
import __main__

def BatchReport():
    step_name = 'form'
    step_number = 1
    save_dir = 'C:/save/directory/here/'
    save_count = 10 # frames count

    view = session.viewports[session.currentViewportName]
    odb_name = view.displayedObject.name
    odb = session.odbs[odb_name]
    count = len(odb.steps[step_name].frames)-1
    print count
    stepsize = int(floor(count/save_count))
    #
    #
    for F in range(count,0,-stepsize) + [0]:
        view.odbDisplay.setFrame(step=step_number, frame=F)
        session.fieldReportOptions.setValues(printTotal=OFF, printMinMax=OFF)
        pad = "%03d" % (F)
        file = save_dir + pad + "_" + step_name + ".rpt"
        session.writeFieldReport(
            fileName=file, 
            append=OFF, sortItem='Node Label',
            odb=odb, step=1, frame=F, 
            outputPosition=NODAL, variable=(
            ('U', NODAL, (
            (COMPONENT, 'U1'),
            (COMPONENT, 'U2'), 
            (COMPONENT, 'U3'), 
            )), 
            ('LE', INTEGRATION_POINT, (
            (INVARIANT, 'Max. In-Plane Principal'), 
            (INVARIANT, 'Min. In-Plane Principal'), 
            )), 
            ))

