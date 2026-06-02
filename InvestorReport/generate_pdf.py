from fpdf import FPDF
from fpdf.enums import XPos, YPos
import os

ASSETS = os.path.join(os.path.dirname(__file__), "assets")
OUTPUT = os.path.join(os.path.dirname(__file__), "CareLens_Aged_Plus_Investor_Report.pdf")


class InvestorReport(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("DejaVu", "", "/System/Library/Fonts/Supplemental/Arial.ttf")
        self.add_font("DejaVu", "B", "/System/Library/Fonts/Supplemental/Arial Bold.ttf")
        self.add_font("DejaVu", "I", "/System/Library/Fonts/Supplemental/Arial Italic.ttf")

    def header(self):
        if self.page_no() > 1:
            self.set_font("DejaVu", "I", 8)
            self.set_text_color(120, 120, 120)
            self.cell(0, 5, "CareLens Aged+ | Investor Report | Confidential", align="C")
            self.ln(8)

    def footer(self):
        self.set_y(-15)
        self.set_font("DejaVu", "I", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f"Page {self.page_no()}/10", align="C")

    def add_cover(self):
        self.add_page()
        self.set_fill_color(15, 10, 40)
        self.rect(0, 0, 210, 297, "F")
        self.image(os.path.join(ASSETS, "promo_01_hero_dashboard.png"), 10, 10, 190)
        self.set_y(145)
        self.set_font("DejaVu", "B", 28)
        self.set_text_color(255, 255, 255)
        self.cell(0, 12, "CareLens Aged+", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
        self.set_font("DejaVu", "I", 16)
        self.set_text_color(218, 185, 80)
        self.cell(0, 10, "Intelligent Care. Better Outcomes.", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
        self.ln(10)
        self.set_font("DejaVu", "", 12)
        self.set_text_color(200, 200, 220)
        self.multi_cell(0, 7,
            "An AI-powered iOS platform transforming aged care delivery through "
            "predictive clinical insights, real-time cognitive monitoring, and "
            "comprehensive biopsychosocial assessment workflows.", align="C")
        self.ln(10)
        self.set_font("DejaVu", "B", 11)
        self.set_text_color(218, 185, 80)
        self.cell(0, 8, "INVESTOR REPORT  |  MAY 2026  |  CONFIDENTIAL", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
        self.ln(15)
        self.set_font("DejaVu", "", 10)
        self.set_text_color(180, 180, 200)
        self.cell(0, 6, "Christopher Appiah-Thompson", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
        self.cell(0, 6, "Founder & CEO", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")
        self.cell(0, 6, "chrsappiah@icloud.com | worldcareservices.com.au", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align="C")

    def add_page_with_image(self, title, image_file, description_lines):
        self.add_page()
        self.set_font("DejaVu", "B", 16)
        self.set_text_color(30, 30, 80)
        self.cell(0, 10, title, new_x=XPos.LMARGIN, new_y=YPos.NEXT)
        self.set_draw_color(218, 185, 80)
        self.set_line_width(0.5)
        self.line(10, self.get_y(), 200, self.get_y())
        self.ln(3)
        img_path = os.path.join(ASSETS, image_file)
        if os.path.exists(img_path):
            self.image(img_path, 10, self.get_y(), 190)
            self.ln(105)
        self.set_font("DejaVu", "", 9)
        self.set_text_color(40, 40, 60)
        for line in description_lines:
            if self.get_y() > 275:
                self.add_page()
                self.set_font("DejaVu", "", 9)
                self.set_text_color(40, 40, 60)
            if line.startswith("##"):
                self.ln(2)
                self.set_font("DejaVu", "B", 10)
                self.set_text_color(30, 30, 80)
                self.cell(0, 5.5, line.replace("## ", ""), new_x=XPos.LMARGIN, new_y=YPos.NEXT)
                self.set_font("DejaVu", "", 9)
                self.set_text_color(40, 40, 60)
            elif line.startswith("- "):
                self.set_x(15)
                self.multi_cell(180, 5, f"- {line[2:]}")
            elif line == "":
                self.ln(1.5)
            else:
                self.set_x(10)
                self.multi_cell(190, 5, line)


pdf = InvestorReport()
pdf.set_auto_page_break(auto=True, margin=20)

# Page 1: Cover
pdf.add_cover()

# Page 2: AI Clinical Intelligence
pdf.add_page_with_image(
    "AI-Driven Clinical Intelligence",
    "promo_02_ai_insights.png",
    [
        "## GPT-4o Powered Clinical Analysis",
        "CareLens Aged+ integrates OpenAI's GPT-4o to deliver real-time clinical decision support for aged care providers.",
        "",
        "## Core Capabilities",
        "- Differential Diagnosis: AI evaluates symptoms, history, and labs to suggest probable differentials",
        "- Care Plan Generation: Personalised, evidence-based care plans adapted to patient needs and risks",
        "- Cognitive Scoring: AI-powered cognitive assessments with standardised scoring and trend analysis",
        "- Report Narratives: Natural language summaries for clear, actionable clinical insights",
        "",
        "## Impact Metrics",
        "- 85% early risk detection accuracy",
        "- 40% reduction in care planning time",
        "- Continuous learning from real-world clinical data",
    ]
)

# Page 3: Biopsychosocial Assessment
pdf.add_page_with_image(
    "Comprehensive Biopsychosocial Assessment",
    "promo_03_client_intake.png",
    [
        "## 7-Step Evidence-Based Clinical Workflow",
        "Our structured intake captures a complete biopsychosocial profile for each client:",
        "",
        "- Step 1: Demographics — Personal and demographic information",
        "- Step 2: Medical History — Conditions, medications, surgical history",
        "- Step 3: Cognitive Screen — Standardised cognitive function screening (MMSE)",
        "- Step 4: Functional Assessment — ADLs, IADLs, and functional capabilities (Katz Index)",
        "- Step 5: Social Support — Family, community, and support network evaluation",
        "- Step 6: Risk Factors — Psychological, safety, and environmental risk profiling",
        "- Step 7: Care Plan — Personalised recommendations and clinical interventions",
        "",
        "Integrated tools: MMSE, Katz ADL Index, Geriatric Depression Scale, Falls Risk Assessment Tool",
    ]
)

# Page 4: Revenue Model
pdf.add_page_with_image(
    "Scalable SaaS Revenue Model",
    "promo_04_service access_model.png",
    [
        "## 4-Tier Administrator-Managed Access",
        "- Free (admin assigned): Basic health overview, 1 Care Circle, 7-day history",
        "- Starter (admin assigned): Unlimited Care Circle, real-time alerts, 30-day history",
        "- Professional (admin assigned): Unlimited clients, custom alerts, 90-day history, priority support",
        "- Enterprise (admin assigned): Multi-location, advanced analytics, API access, dedicated manager",
        "",
        "## 5-Year Revenue Projections",
        "2025: $1.2M ARR (5K users) | 2026: $2.8M (12K) | 2027: $6.5M (28K)",
        "2028: $12.5M (55K) | 2029: $21.5M (95K) | 2030: $35M+ (150K+)",
        "",
        "Seamless administrator provisioning integration for frictionless service access conversion.",
    ]
)

# Page 5: NeuroWatch
pdf.add_page_with_image(
    "NeuroWatch - Early Detection Engine",
    "promo_05_neurowatch_monitoring.png",
    [
        "## Proprietary Cognitive Scoring Algorithm",
        "NeuroWatch fuses behavioural, cognitive, and functional data to detect subtle cognitive changes months before clinical presentation.",
        "",
        "## Performance Metrics",
        "- Early Detection Rate: 94%",
        "- False Positive Rate: <3%",
        "- Monitoring Frequency: Continuous, real-time analysis",
        "",
        "## Clinical Zones",
        "- Stable (80-100): Normal cognitive function, routine monitoring",
        "- Declining (50-79): Early signs requiring clinical attention and review",
        "- Critical (0-49): Immediate intervention and specialist referral needed",
        "",
        "Adaptive learning continuously personalises scoring per individual baseline.",
    ]
)

# Page 6: Platform Overview
pdf.add_page_with_image(
    "Platform Overview & Market Opportunity",
    "promo_06_platform_overview.png",
    [
        "## Six Core Pillars",
        "- Clinical Dashboard: Real-time health overview, alerts, and care plans",
        "- AI Insights: GPT-4o powered risk predictions and care optimisation",
        "- Client Intake: Digital biopsychosocial assessments and document capture",
        "- NeuroWatch: Proprietary cognitive health monitoring engine",
        "- Admin Panel: Role-based access, compliance, account administration management",
        "- CloudKit Sync: Secure synchronisation across all Apple devices",
        "",
        "## Market Opportunity",
        "- Global Aged Care Tech Market (2028): $12.4 Billion",
        "- Care Recipients in Australia: 3.8 Million+",
        "- Total Addressable Market: $2.1 Billion",
        "- Industry CAGR: 12.4% driven by aging population and digital mandates",
    ]
)

# Page 7: Security
pdf.add_page_with_image(
    "Enterprise-Grade Security & Compliance",
    "promo_07_security_admin.png",
    [
        "## Security Architecture",
        "- End-to-End Encryption: AES-256 for all data at rest and in transit",
        "- Role-Based Access Control: Admin, Clinician, Carer, Family granular permissions",
        "- Audit Trail Logging: Complete activity tracking for compliance and governance",
        "- Biometric Authentication: Face ID / Touch ID device-level security",
        "",
        "## Administration Panel",
        "Full user management, service access oversight, organisation configuration, compliance reporting, and real-time system health monitoring.",
        "",
        "## Compliance Certifications (Targeted)",
        "SOC 2 Type II | HIPAA | Australian Privacy Act 1988 | ISO 27001",
    ]
)

# Page 8: Tech Architecture
pdf.add_page_with_image(
    "Modern Native Architecture",
    "promo_08_tech_architecture.png",
    [
        "## Technology Stack",
        "- Frontend: SwiftUI, Swift 5.9 — native, performant, accessible",
        "- Data Persistence: SwiftData — modern Apple persistence framework",
        "- Cloud Sync: CloudKit (Apple) + Supabase (PostgreSQL backup)",
        "- AI Engine: OpenAI GPT-4o API via NetworkMiddleware",
        "- Access: Admin-managed access, administrator provisioning seamless service access",
        "- CI/CD: GitHub Actions -> TestFlight -> App Store (automated)",
        "",
        "## Architecture Principles",
        "- Privacy by Design: On-device processing, minimal data transfer",
        "- Offline First: Full functionality without internet connectivity",
        "- Observable: Comprehensive monitoring, logging, and error tracking",
        "- Deployment: GitHub -> CI/CD (Build + Test) -> TestFlight -> App Store",
    ]
)

# Page 9: Roadmap
pdf.add_page_with_image(
    "Vision & Product Roadmap",
    "promo_09_roadmap.png",
    [
        "## Product Roadmap 2025-2027",
        "- Q1 2025: MVP Launch — Core monitoring, Care Circle, notifications",
        "- Q2 2025: TestFlight Beta — Invite-only, user feedback, iteration",
        "- Q3 2025: App Store Release — Public launch, onboarding campaign",
        "- Q4 2025: Enterprise Partnerships — Strategic alliances, white-label",
        "- 2026: HealthKit & Wearables — Apple Watch, device integration",
        "- 2027: AI v2.0 & International Expansion — Multi-language, global scale",
        "",
        "## Current Status (May 2026)",
        "- MVP feature-complete and deployed to physical devices",
        "- TestFlight build uploaded and processing on App Store Connect",
        "- CI/CD pipeline fully operational with automated quality gates",
        "- Enterprise partnership discussions actively in progress",
    ]
)

# Page 10: Investment Opportunity
pdf.add_page_with_image(
    "Investment Opportunity",
    "promo_10_closing_cta.png",
    [
        "## Seeking: $1.5M Seed Round",
        "",
        "## Use of Funds",
        "- Engineering (40%): Team expansion, AI R&D, platform scaling",
        "- Go-to-Market (25%): Sales, marketing, enterprise partnerships",
        "- Compliance (15%): SOC2, HIPAA certification, legal framework",
        "- Operations (10%): Infrastructure, cloud services, support",
        "- Reserve (10%): Runway extension, contingency buffer",
        "",
        "## Key Investment Highlights",
        "- Large & growing $12.4B global aged care tech market",
        "- Proprietary NeuroWatch AI engine — defensible competitive moat",
        "- Revenue-ready 4-tier SaaS model with administrator provisioning",
        "- Product-market fit — built by clinicians, for clinicians",
        "- Scalable native iOS architecture with cloud-native backend",
        "- Regulatory tailwinds driving mandatory digital adoption",
        "",
        "Contact: Christopher Appiah-Thompson | chrsappiah@icloud.com | worldcareservices.com.au",
    ]
)

pdf.output(OUTPUT)
print(f"PDF generated: {OUTPUT}")
