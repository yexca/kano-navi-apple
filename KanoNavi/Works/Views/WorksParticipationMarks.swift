import KanoNaviComponents
import KanoNaviCore
import SwiftUI

/// What Kano did on a participation work and the form it came in, as a
/// wrapping row of chips.
struct WorksParticipationMarks: View {
    let work: WorksParticipation

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(work.roles.uniqued(), id: \.self) { role in
                ComponentChip(title: WorksCodeLabels.role(role), tint: .pink)
            }
            ForEach(work.forms.uniqued(), id: \.self) { form in
                ComponentChip(title: WorksCodeLabels.form(form), tint: .secondary)
            }
            if let unit = work.unit, unit.isEmpty == false {
                ComponentChip(title: .Works.unitNamed(unit), systemImage: "person.2.fill", tint: .purple)
            }
        }
    }
}
