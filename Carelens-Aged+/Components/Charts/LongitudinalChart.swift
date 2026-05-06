import SwiftUI
import Charts

struct LongitudinalChart: View {
    let title: String
    let data: [ChartDataPoint]
    let color: Color
    let yAxisLabel: String

    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let label: String?

        init(date: Date, value: Double, label: String? = nil) {
            self.date = date
            self.value = value
            self.label = label
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if data.isEmpty {
                Text("No data available")
                    .font(.subheadline)
                    .foregroundStyle(CLTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value(yAxisLabel, point.value)
                    )
                    .foregroundStyle(color)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value(yAxisLabel, point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value(yAxisLabel, point.value)
                    )
                    .foregroundStyle(color)
                    .symbolSize(30)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
            }
        }
        .clCard()
    }
}
