import Foundation

struct AIInsightRequest: Codable {
    let model: String
    let messages: [AIMessage]
    let temperature: Double
    let max_tokens: Int
}

struct AIMessage: Codable {
    let role: String
    let content: String
}

struct AIInsightResponse: Codable {
    let id: String
    let choices: [AIChoice]
}

struct AIChoice: Codable {
    let message: AIMessage
}

struct ClinicalInsight: Identifiable {
    let id = UUID()
    let category: String
    let summary: String
    let recommendations: [String]
    let confidence: Double
    let generatedAt: Date
}

actor HealthAPIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let session: URLSession

    init(apiKey: String = "") {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    func generateClinicalInsight(
        assessmentType: String,
        scores: [String: Double],
        clientAge: Int,
        concerns: String
    ) async throws -> ClinicalInsight {
        let prompt = buildClinicalPrompt(
            assessmentType: assessmentType,
            scores: scores,
            clientAge: clientAge,
            concerns: concerns
        )

        let request = AIInsightRequest(
            model: "gpt-4o",
            messages: [
                AIMessage(role: "system", content: systemPrompt),
                AIMessage(role: "user", content: prompt)
            ],
            temperature: 0.3,
            max_tokens: 1000
        )

        let response = try await sendRequest(request)
        return parseInsight(from: response, category: assessmentType)
    }

    func generateDifferentialAnalysis(
        symptoms: [String: Any]
    ) async throws -> ClinicalInsight {
        let symptomsDescription = symptoms.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        let prompt = """
        Analyse the following symptom profile for an older adult and provide differential considerations between depression, anxiety, progressive cognitive decline, and delirium. Emphasise that this is decision-support, not diagnosis.
        
        Symptoms: \(symptomsDescription)
        
        Provide: 1) Most likely pattern, 2) Key differentiators, 3) Recommended next steps, 4) Red flags to watch for.
        """

        let request = AIInsightRequest(
            model: "gpt-4o",
            messages: [
                AIMessage(role: "system", content: systemPrompt),
                AIMessage(role: "user", content: prompt)
            ],
            temperature: 0.3,
            max_tokens: 1200
        )

        let response = try await sendRequest(request)
        return parseInsight(from: response, category: "Differential Analysis")
    }

    func generateCarePlanSuggestions(
        strengths: [String],
        problems: [String],
        assessmentScores: [String: Double]
    ) async throws -> ClinicalInsight {
        let prompt = """
        Based on the following biopsychosocial assessment data for an older adult, suggest evidence-based care plan components.
        
        Strengths: \(strengths.joined(separator: "; "))
        Priority Problems: \(problems.joined(separator: "; "))
        Scores: \(assessmentScores.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
        
        Provide: 1) Goal suggestions, 2) Intervention recommendations (psychosocial, medical, environmental, spiritual), 3) Review timeline, 4) Key monitoring indicators.
        """

        let request = AIInsightRequest(
            model: "gpt-4o",
            messages: [
                AIMessage(role: "system", content: systemPrompt),
                AIMessage(role: "user", content: prompt)
            ],
            temperature: 0.4,
            max_tokens: 1200
        )

        let response = try await sendRequest(request)
        return parseInsight(from: response, category: "Care Plan AI Suggestions")
    }

    func generateReportNarrative(
        reportType: String,
        clientName: String,
        assessmentData: [String: String]
    ) async throws -> String {
        let dataDescription = assessmentData.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        let prompt = """
        Generate a \(reportType) narrative for client \(clientName) based on the following structured assessment data. Use appropriate clinical tone for the report type.
        
        Data:
        \(dataDescription)
        
        Format the output as a professional \(reportType) suitable for aged-care documentation.
        """

        let request = AIInsightRequest(
            model: "gpt-4o",
            messages: [
                AIMessage(role: "system", content: systemPrompt),
                AIMessage(role: "user", content: prompt)
            ],
            temperature: 0.4,
            max_tokens: 2000
        )

        let response = try await sendRequest(request)
        return response.choices.first?.message.content ?? "Unable to generate narrative."
    }

    // MARK: - Private

    private var systemPrompt: String {
        """
        You are a clinical decision-support assistant for aged-care professionals using the CareLens Age+ platform. Your role is to:
        - Provide evidence-based suggestions, never definitive diagnoses
        - Emphasise that all cognitive outputs are screening indicators, not diagnostic conclusions
        - Consider biopsychosocial factors including physical, psychological, social, spiritual, and environmental domains
        - Flag when acute fluctuation may indicate delirium requiring urgent medical assessment
        - Use strengths-based language alongside risk identification
        - Distinguish screening from diagnosis, especially for cognitive decline, depression, anxiety, and delirium
        - Support longitudinal monitoring rather than single-point conclusions
        - Keep outputs audience-appropriate (clinical detail for professionals, plain language for families)
        
        IMPORTANT: Always include a disclaimer that this is decision-support only and does not replace clinical judgment.
        """
    }

    private func buildClinicalPrompt(assessmentType: String, scores: [String: Double], clientAge: Int, concerns: String) -> String {
        let scoreText = scores.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        return """
        Assessment Type: \(assessmentType)
        Client Age: \(clientAge)
        Scores: \(scoreText)
        Presenting Concerns: \(concerns)
        
        Provide: 1) Clinical interpretation of scores in context, 2) Key considerations, 3) Recommended actions, 4) Monitoring suggestions.
        """
    }

    private func sendRequest(_ request: AIInsightRequest) async throws -> AIInsightResponse {
        guard !apiKey.isEmpty else {
            return AIInsightResponse(
                id: "mock_\(UUID().uuidString)",
                choices: [
                    AIChoice(message: AIMessage(
                        role: "assistant",
                        content: "[AI Insight] Based on the assessment data, key considerations include monitoring for progressive changes, reviewing medication interactions, and ensuring adequate social support. Recommend follow-up in 4-6 weeks with collateral history. Note: This is decision-support only and does not replace clinical judgment."
                    ))
                ]
            )
        }

        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw HealthAPIError.requestFailed
        }
        return try JSONDecoder().decode(AIInsightResponse.self, from: data)
    }

    private func parseInsight(from response: AIInsightResponse, category: String) -> ClinicalInsight {
        let content = response.choices.first?.message.content ?? ""
        let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
        let summary = lines.first ?? "Analysis complete"
        let recommendations = lines.dropFirst().map { $0.trimmingCharacters(in: .whitespaces) }

        return ClinicalInsight(
            category: category,
            summary: summary,
            recommendations: recommendations,
            confidence: 0.75,
            generatedAt: .now
        )
    }

    enum HealthAPIError: Error {
        case requestFailed
        case invalidResponse
        case apiKeyMissing
    }
}
