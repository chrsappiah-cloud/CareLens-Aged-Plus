import SwiftUI

struct ClinicalReference: Identifiable {
    let id = UUID()
    let title: String
    let authors: String
    let year: String
    let url: URL?
}

struct ClinicalReferencesView: View {
    let references: [ClinicalReference]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                    Text("Clinical References & Evidence Base")
                        .font(.subheadline.bold())
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(CareLensTheme.Colors.textTertiary)
                        .font(.caption)
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This tool draws on the following peer-reviewed instruments and guidelines. These references are provided for clinician transparency. This app is a clinical decision-support aid and does not replace professional judgement.")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textTertiary)
                        .padding(.bottom, 4)

                    ForEach(references) { ref in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "doc.text")
                                    .font(.caption)
                                    .foregroundStyle(CareLensTheme.Colors.accentMint)
                                    .padding(.top, 1)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ref.title)
                                        .font(.caption.bold())
                                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                                    Text("\(ref.authors) (\(ref.year))")
                                        .font(.caption2)
                                        .foregroundStyle(CareLensTheme.Colors.textTertiary)
                                    if let url = ref.url {
                                        Link("View source →", destination: url)
                                            .font(.caption2)
                                            .foregroundStyle(CareLensTheme.Colors.accentMint)
                                    }
                                }
                            }
                            Divider().overlay(Color.white.opacity(0.08))
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clCard()
    }
}

// MARK: - Predefined reference sets

extension ClinicalReferencesView {
    static func neuroWatch() -> ClinicalReferencesView {
        ClinicalReferencesView(references: [
            ClinicalReference(
                title: "Montreal Cognitive Assessment (MoCA)",
                authors: "Nasreddine ZS et al.",
                year: "2005",
                url: URL(string: "https://www.mocatest.org")
            ),
            ClinicalReference(
                title: "Mini-Mental State Examination (MMSE)",
                authors: "Folstein MF, Folstein SE, McHugh PR",
                year: "1975",
                url: URL(string: "https://doi.org/10.1016/0022-3956(75)90026-6")
            ),
            ClinicalReference(
                title: "Clock Drawing Test — Clinical Review",
                authors: "Shulman KI",
                year: "2000",
                url: URL(string: "https://doi.org/10.1017/S1041610200004580")
            ),
            ClinicalReference(
                title: "Category Verbal Fluency — Normative Data",
                authors: "Tombaugh TN, Kozak J, Rees L",
                year: "1999",
                url: URL(string: "https://doi.org/10.1037/0894-4105.13.4.615")
            ),
            ClinicalReference(
                title: "Confusion Assessment Method (CAM) for Delirium",
                authors: "Inouye SK et al.",
                year: "1990",
                url: URL(string: "https://doi.org/10.7326/0003-4819-113-12-941")
            ),
            ClinicalReference(
                title: "Australian Clinical Practice Guidelines for Dementia",
                authors: "Dementia Australia / NHMRC",
                year: "2016",
                url: URL(string: "https://www.nhmrc.gov.au/about-us/publications/clinical-practice-guidelines-and-principles-care-people-dementia")
            ),
        ])
    }

    static func differential() -> ClinicalReferencesView {
        ClinicalReferencesView(references: [
            ClinicalReference(
                title: "Geriatric Depression Scale (GDS)",
                authors: "Yesavage JA et al.",
                year: "1982",
                url: URL(string: "https://doi.org/10.1016/0022-3956(82)90033-4")
            ),
            ClinicalReference(
                title: "Diagnostic and Statistical Manual of Mental Disorders, 5th Ed. (DSM-5)",
                authors: "American Psychiatric Association",
                year: "2013",
                url: URL(string: "https://www.psychiatry.org/psychiatrists/practice/dsm")
            ),
            ClinicalReference(
                title: "Confusion Assessment Method (CAM) — Delirium Detection",
                authors: "Inouye SK et al.",
                year: "1990",
                url: URL(string: "https://doi.org/10.7326/0003-4819-113-12-941")
            ),
            ClinicalReference(
                title: "Generalised Anxiety Disorder Scale (GAD-7)",
                authors: "Spitzer RL et al.",
                year: "2006",
                url: URL(string: "https://doi.org/10.1001/archinte.166.10.1092")
            ),
            ClinicalReference(
                title: "Neuropsychiatric Inventory (NPI)",
                authors: "Cummings JL et al.",
                year: "1994",
                url: URL(string: "https://doi.org/10.1212/WNL.44.12.2308")
            ),
        ])
    }

    static func biopsychosocial() -> ClinicalReferencesView {
        ClinicalReferencesView(references: [
            ClinicalReference(
                title: "Biopsychosocial Model in Aged Care — Framework",
                authors: "Engel GL",
                year: "1977",
                url: URL(string: "https://doi.org/10.1126/science.847460")
            ),
            ClinicalReference(
                title: "Activities of Daily Living (ADL/IADL) — Barthel Index",
                authors: "Mahoney FI, Barthel DW",
                year: "1965",
                url: URL(string: "https://doi.org/10.1097/00005768-198511000-00001")
            ),
            ClinicalReference(
                title: "Lawton Instrumental ADL Scale",
                authors: "Lawton MP, Brody EM",
                year: "1969",
                url: URL(string: "https://doi.org/10.1093/geronj/24.2.179")
            ),
            ClinicalReference(
                title: "AASW Practice Standards for Social Work in Aged Care",
                authors: "Australian Association of Social Workers (AASW)",
                year: "2021",
                url: URL(string: "https://www.aasw.asn.au/practitioner-resources/practice-standards")
            ),
            ClinicalReference(
                title: "Aged Care Quality Standards — Australian Government",
                authors: "Aged Care Quality and Safety Commission",
                year: "2019",
                url: URL(string: "https://www.agedcarequality.gov.au/providers/standards")
            ),
        ])
    }

    static func functionSafety() -> ClinicalReferencesView {
        ClinicalReferencesView(references: [
            ClinicalReference(
                title: "Falls Prevention in Older People — Clinical Guidelines",
                authors: "NSW Ministry of Health",
                year: "2017",
                url: URL(string: "https://www.health.nsw.gov.au/fallsprevention")
            ),
            ClinicalReference(
                title: "Timed Up and Go Test (TUG) for Falls Risk",
                authors: "Podsiadlo D, Richardson S",
                year: "1991",
                url: URL(string: "https://doi.org/10.1111/j.1532-5415.1991.tb01616.x")
            ),
        ])
    }
}
