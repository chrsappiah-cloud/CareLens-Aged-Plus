#!/usr/bin/env python3
"""Generate 250-page World Class Scholars promotional PDF report."""

import os, math
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm, cm, inch
from reportlab.lib.colors import HexColor, white, black, Color
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle,
    PageBreak, Frame, PageTemplate, BaseDocTemplate, KeepTogether,
    ListFlowable, ListItem, NextPageTemplate
)
from reportlab.platypus.flowables import Flowable
from reportlab.graphics.shapes import (
    Drawing, Rect, String, Circle, Line, Polygon, Image as GImage,
    Wedge, Group
)
from reportlab.graphics import renderPDF
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from io import BytesIO
import textwrap
import random

# ─── Color Palette ───
GOLD = HexColor("#D4AF37")
DARK = HexColor("#0D0D0D")
DARK2 = HexColor("#1A1A2E")
ACCENT = HexColor("#16213E")
LIGHT = HexColor("#F5F5DC")
TEAL = HexColor("#0F3460")
CRIMSON = HexColor("#8B0000")
WHITE = white
BLACK = black
GRAY = HexColor("#CCCCCC")
DARKGRAY = HexColor("#333333")

OUTPUT_PATH = os.path.expanduser("~/Desktop/WCS_World_Class_Scholars_Portfolio_Report.pdf")

class DrawingFlowable(Flowable):
    """A Flowable that wraps a reportlab Drawing and renders it directly."""
    def __init__(self, drawing, width=None, height=None):
        self.drawing = drawing
        w = width or drawing.width
        h = height or drawing.height
        Flowable.__init__(self)
        self.width = w
        self.height = h

    def draw(self):
        renderPDF.draw(self.drawing, self.canv, 0, 0)

# ─── Utility ───
def make_circle_icon(code, size=24, color=GOLD):
    d = Drawing(size, size)
    d.add(Circle(size/2, size/2, size/2-1, fillColor=color, strokeColor=None))
    d.add(String(size/2, size/2-4, code, textAnchor='middle', fontSize=10,
                 fillColor=WHITE, fontName='Helvetica-Bold'))
    return d

def gradient_rect(width, height, c1, c2):
    """Simple gradient approximation using overlapping rects."""
    d = Drawing(width, height)
    steps = 20
    for i in range(steps):
        t = i / steps
        r = c1.red + (c2.red - c1.red) * t
        g = c1.green + (c2.green - c1.green) * t
        b = c1.blue + (c2.blue - c1.blue) * t
        y = height * t
        h = height / steps + 1
        d.add(Rect(0, y, width, h, fillColor=Color(r, g, b), strokeColor=None))
    return d

def banner(title, subtitle="", width=500, height=80):
    d = Drawing(width, height)
    d.add(Rect(0, 0, width, height, fillColor=DARK2, strokeColor=None))
    d.add(Rect(0, height-3, width, 3, fillColor=GOLD, strokeColor=None))
    d.add(String(20, height-30, title, fontName='Helvetica-Bold',
                 fontSize=22, fillColor=GOLD))
    if subtitle:
        d.add(String(20, height-55, subtitle, fontName='Helvetica',
                     fontSize=12, fillColor=GRAY))
    return d

def app_screenshot_mockup(title, desc, color1=DARK2, color2=ACCENT, width=460, height=260):
    """Generate a mockup 'screenshot' for an app."""
    d = Drawing(width, height)
    d.add(Rect(0, 0, width, height, fillColor=color1, strokeColor=GOLD,
               strokeWidth=1))
    # device bezel
    bezel_w, bezel_h = width-40, height-40
    bx, by = 20, 20
    d.add(Rect(bx, by, bezel_w, bezel_h, fillColor=color2, strokeColor=GOLD,
               strokeWidth=0.5, rx=8, ry=8))
    # status bar
    d.add(Rect(bx+10, by+bezel_h-30, bezel_w-20, 20, fillColor=color1,
               strokeColor=None, rx=4, ry=4))
    d.add(String(width/2, by+bezel_h-22, "9:41", fontName='Helvetica-Bold',
                 fontSize=10, fillColor=WHITE, textAnchor='middle'))
    # title
    d.add(String(width/2, by+bezel_h-70, title, fontName='Helvetica-Bold',
                 fontSize=16, fillColor=GOLD, textAnchor='middle'))
    # description
    d.add(String(width/2, by+100, desc, fontName='Helvetica',
                 fontSize=10, fillColor=GRAY, textAnchor='middle'))
    # feature boxes
    for i in range(3):
        fx = bx + 20 + i * ((bezel_w-60)/3 + 10)
        fy = by + 30
        fw = (bezel_w-60)/3
        fh = 50
        d.add(Rect(fx, fy, fw, fh, fillColor=color1, strokeColor=GOLD,
                   strokeWidth=0.3, rx=4, ry=4))
    return d

def full_page_screenshot(title, desc, screen_index, app_name, width=460, height=680):
    """Generate a detailed full-page mockup for an app screenshot."""
    hues = [
        (DARK2, ACCENT), (ACCENT, TEAL), (DARK, DARK2),
        (TEAL, ACCENT), (HexColor("#1a1a2e"), HexColor("#16213e")),
        (HexColor("#0d0d0d"), HexColor("#1a1a2e")), (DARK2, HexColor("#0F3460")),
        (HexColor("#1a1a2e"), DARK2), (HexColor("#16213e"), TEAL), (HexColor("#0d0d0d"), ACCENT),
    ]
    c1, c2 = hues[screen_index % len(hues)]
    d = Drawing(width, height)
    # Background gradient approximation
    steps = 30
    for i in range(steps):
        t = i / steps
        r = c1.red + (c2.red - c1.red) * t
        g = c1.green + (c2.green - c1.green) * t
        b = c1.blue + (c2.blue - c1.blue) * t
        y = height * t
        h = height / steps + 1
        d.add(Rect(0, y, width, h, fillColor=Color(r, g, b), strokeColor=None))
    # Outer border
    d.add(Rect(2, 2, width-4, height-4, fillColor=None, strokeColor=GOLD, strokeWidth=1.5, rx=6, ry=6))
    # Status bar area
    d.add(Rect(10, height-40, width-20, 28, fillColor=Color(0,0,0,0.3), strokeColor=None, rx=4, ry=4))
    d.add(String(20, height-30, "9:41", fontName='Helvetica-Bold', fontSize=12, fillColor=WHITE))
    d.add(String(width-20, height-30, "100%", fontName='Helvetica', fontSize=10, fillColor=GRAY, textAnchor='end'))
    # Screen title header
    hdr_y = height - 80
    d.add(Rect(10, hdr_y-30, width-20, 40, fillColor=DARK, strokeColor=GOLD, strokeWidth=0.5, rx=4, ry=4))
    d.add(String(width/2, hdr_y-22, title, fontName='Helvetica-Bold', fontSize=18, fillColor=GOLD, textAnchor='middle'))
    d.add(String(width/2, hdr_y-40, f"{app_name}", fontName='Helvetica', fontSize=9, fillColor=GRAY, textAnchor='middle'))
    # Content area - feature grid
    num_features = 4
    fw = (width - 60) / num_features
    for i in range(num_features):
        fx = 20 + i * (fw + 8)
        fy = height - 160
        fh = 90
        d.add(Rect(fx, fy, fw, fh, fillColor=Color(0,0,0,0.2), strokeColor=GOLD, strokeWidth=0.3, rx=4, ry=4))
        d.add(String(fx+fw/2, fy+fh/2+10, f"Feature {i+1}", fontName='Helvetica-Bold', fontSize=9, fillColor=GOLD, textAnchor='middle'))
        d.add(String(fx+fw/2, fy+fh/2-10, f"Description", fontName='Helvetica', fontSize=7, fillColor=GRAY, textAnchor='middle'))
    # Data visualization area
    chart_y = height - 280
    d.add(Rect(20, chart_y, width-40, 100, fillColor=Color(0,0,0,0.15), strokeColor=HexColor("#444444"), strokeWidth=0.3, rx=4, ry=4))
    d.add(String(35, chart_y+80, "Analytics Overview", fontName='Helvetica-Bold', fontSize=11, fillColor=GOLD))
    # Simulated bars
    bar_w = (width - 80) / 6
    for i in range(6):
        bx = 30 + i * (bar_w + 5)
        bh = 20 + (i * 8) % 50
        d.add(Rect(bx, chart_y+10, bar_w-2, bh, fillColor=HexColor("#D4AF37"), strokeColor=None, rx=2, ry=2))
        d.add(String(bx+bar_w/2-1, chart_y+5, f"{bh}", fontName='Helvetica', fontSize=6, fillColor=GRAY, textAnchor='middle'))
    # Bottom action area
    btn_y = 30
    btn_w = (width - 80) / 3
    for i in range(3):
        bx = 20 + i * (btn_w + 12)
        d.add(Rect(bx, btn_y, btn_w, 35, fillColor=GOLD, strokeColor=None, rx=4, ry=4))
        labels = ["Primary", "Secondary", "Tertiary"]
        d.add(String(bx+btn_w/2, btn_y+14, labels[i], fontName='Helvetica-Bold', fontSize=9, fillColor=BLACK, textAnchor='middle'))
    # Description text
    d.add(String(20, height-190, desc, fontName='Helvetica', fontSize=9, fillColor=GRAY))
    # Version badge
    d.add(Rect(width-100, 8, 80, 18, fillColor=DARK, strokeColor=GOLD, strokeWidth=0.3, rx=3, ry=3))
    d.add(String(width-60, 18, f"v1.0.{screen_index+1}", fontName='Helvetica', fontSize=7, fillColor=GOLD, textAnchor='middle'))
    return d

def feature_box(title, items, width=460):
    """Table-based feature box."""
    data = [[Paragraph(f"<b>{title}</b>", ParagraphStyle('fh', fontSize=12,
            textColor=GOLD, fontName='Helvetica-Bold'))]]
    for item in items:
        data.append([Paragraph(f"• {item}", ParagraphStyle('fi', fontSize=9,
                                textColor=GRAY, leading=14))])
    t = Table(data, colWidths=[width])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('BACKGROUND', (0,1), (-1,-1), DARK),
        ('TEXTCOLOR', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,1), (-1,-1), GRAY),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.2, HexColor("#333333")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
    ]))
    return t

def section_separator(title, width=500):
    d = Drawing(width, 30)
    d.add(Rect(0, 0, width, 30, fillColor=DARK2, strokeColor=None))
    d.add(Line(0, 15, 80, 15, strokeColor=GOLD, strokeWidth=1))
    d.add(String(width/2, 9, title, fontName='Helvetica-Bold',
                 fontSize=12, fillColor=GOLD, textAnchor='middle'))
    d.add(Line(width-80, 15, width, 15, strokeColor=GOLD, strokeWidth=1))
    return d

# ─── Styles ───
styles = getSampleStyleSheet()

body_style = ParagraphStyle('Body2', parent=styles['Normal'],
    fontSize=9.5, leading=14, textColor=GRAY, spaceAfter=6,
    fontName='Helvetica')

h1_style = ParagraphStyle('H1Custom', parent=styles['Heading1'],
    fontSize=24, textColor=GOLD, spaceAfter=12, spaceBefore=20,
    fontName='Helvetica-Bold')

h2_style = ParagraphStyle('H2Custom', parent=styles['Heading2'],
    fontSize=16, textColor=GOLD, spaceAfter=8, spaceBefore=12,
    fontName='Helvetica-Bold')

h3_style = ParagraphStyle('H3Custom', parent=styles['Heading3'],
    fontSize=12, textColor=HexColor("#E8C547"), spaceAfter=6, spaceBefore=8,
    fontName='Helvetica-Bold')

title_style = ParagraphStyle('TitleCustom',
    fontSize=36, textColor=GOLD, spaceAfter=6, fontName='Helvetica-Bold',
    alignment=TA_CENTER)

subtitle_style = ParagraphStyle('SubCustom',
    fontSize=14, textColor=GRAY, spaceAfter=20, fontName='Helvetica',
    alignment=TA_CENTER)

bullet_style = ParagraphStyle('BulletCustom',
    fontSize=9, textColor=GRAY, leading=13, leftIndent=15, spaceAfter=2,
    fontName='Helvetica', bulletIndent=5)

# App definitions
APPS = [
    {
        "name": "medlingo",
        "tagline": "AI-Powered Medical Terminology Learning Platform",
        "category": "Medical / Education",
        "testflight": "Available via invite (2 beta groups: chrsappiah@gmail.com, lako.julia@yahoo.com)",
        "appstore": "Coming Soon to App Store",
        "desc": [
            "Medlingo is an AI-powered medical terminology tutor designed for medical students, nursing professionals, and healthcare workers. It transforms complex medical vocabulary learning through engaging AI avatar sessions, interactive lessons, and spaced repetition.",
            "With structured chapters covering anatomy, pathology, pharmacology, and more, medlingo uses cutting-edge AI to personalize each learner's journey. The app features a gold-and-diamond advanced UI that makes medical education feel world-class.",
        ],
        "features": [
            "AI Avatar Tutor with synchronized speech and visual aids",
            "Audio pronunciation with phonetic breakdowns",
            "Structured curriculum across all medical domains",
            "Spaced repetition for optimal long-term retention",
            "Interactive Practice Lab with flashcards and quizzes",
            "Anatomy labeling exercises with visual feedback",
            "Progress tracking with detailed analytics",
            "Offline support for study anywhere",
            "Collection gallery for medical visuals",
            "Admin-managed access advanced service access",
            "Multiple learning modes (visual, auditory, kinesthetic)",
            "Exam preparation modules for USMLE, NCLEX, and more",
        ],
        "audience": [
            "Medical students and residents",
            "Nursing students and professionals",
            "Pre-med and healthcare sciences students",
            "International medical graduates",
            "Healthcare administrators",
            "Medical transcriptionists and coders",
        ],
        "enterprise": {
            "standard": "admin assigned – Full access, all chapters, AI tutor",
            "annual": "admin assigned – 50% savings, all features",
            "institutional": "admin assigned – Up to 100 seats, admin dashboard, custom curriculum",
        },
        "investment": "The medical education market exceeds $80B globally. Medlingo targets the $5B medical terminology segment with a differentiated AI-tutor approach. Yr1 projection of AU$30K with clear path to AU$200K by Yr3 through institutional sales.",
        "screens": [
            ("Learn Home", "Personalized learning dashboard with streak tracking"),
            ("AI Tutor", "Interactive avatar tutor session"),
            ("Practice Lab", "Flashcard and quiz interface"),
            ("Anatomy", "Interactive anatomy labeling exercises"),
            ("Chapters", "Structured curriculum browser"),
            ("Pronunciation", "Audio pronunciation with phonetics"),
            ("Progress", "Learning analytics dashboard"),
            ("Collection", "Medical visual reference gallery"),
            ("Stages", "Staged learning progression system"),
            ("Profile", "User profile and achievements"),
        ],
    },
    {
        "name": "Carelens-Aged+",
        "tagline": "Dementia & Aged Care Intelligence Platform",
        "category": "Healthcare / MedTech",
        "testflight": "Available via invite (2 beta groups: chrsappiah@gmail.com, lako.julia@yahoo.com)",
        "appstore": "Search 'Carelens' on App Store (Coming Soon)",
        "desc": [
            "Carelens-Aged+ is a comprehensive, AI-powered aged care management platform designed to transform dementia and elderly care delivery. Built with SwiftUI and SwiftData, it provides care teams with real-time monitoring, assessment tools, care plan automation, and family engagement features.",
            "The platform integrates deeply with HealthKit, CloudKit, and Supabase to provide a seamless, secure, and compliant care management experience. From biopsychosocial assessments to incident logging and neuro watch monitoring, Carelens-Aged+ puts every tool a care team needs into one elegant interface.",
        ],
        "features": [
            "AI-Powered Biopsychosocial Assessments with intelligent insights",
            "Real-time NeuroWatch monitoring and cognitive decline tracking",
            "Automated Care Plan generation and management",
            "Incident logging with photo/video evidence capture",
            "Multi-disciplinary team collaboration platform",
            "HealthKit integration for vital sign monitoring",
            "CloudKit-backed secure data synchronization",
            "Offline-first architecture with conflict resolution",
            "Dark mode optimized UI for low-light care environments",
            "Comprehensive reporting suite with PDF export",
            "Multi-language support for diverse care teams",
            "Family portal for real-time loved one updates",
        ],
        "audience": [
            "Aged care facility operators and managers",
            "Dementia care specialists and neurologists",
            "Community aged care providers",
            "Home care package managers",
            "Family members of care recipients",
            "Allied health professionals",
        ],
        "enterprise": {
            "basic": "admin assigned – Up to 10 care recipients, basic assessments",
            "professional": "admin assigned – Up to 50 recipients, AI insights, family portal",
            "enterprise": "admin assigned – Unlimited recipients, full API, dedicated support",
        },
        "investment": "Carelens-Aged+ addresses a $350B global aged care market growing at 8% CAGR. With AU$25K projected Yr1 revenue and a scalable SaaS model, it represents a low-risk entry into the exploding HealthTech sector. Enterprise contracts average $3,600/yr with 90%+ retention.",
        "screens": [
            ("Dashboard", "Real-time care overview with key metrics"),
            ("Assessments", "AI-powered biopsychosocial evaluation"),
            ("Care Plans", "Automated care plan generation"),
            ("NeuroWatch", "Cognitive decline monitoring dashboard"),
            ("Incident Log", "Photo/video incident reporting"),
            ("Monitoring", "Vital signs and health trends"),
            ("Reports", "PDF report generation suite"),
            ("Team Hub", "Multi-disciplinary collaboration"),
            ("Family Portal", "Real-time family updates"),
            ("Settings", "Enterprise configuration hub"),
        ],
    },
    {
        "name": "Psychosocial Analytics",
        "tagline": "Mental Health Assessment & Analytics Platform",
        "category": "Healthcare / Mental Health",
        "testflight": "Available via invite (Internal Testers beta group)",
        "appstore": "Coming Soon to App Store",
        "desc": [
            "Psychosocial Analytics is a specialized mental health assessment platform that provides comprehensive psychosocial evaluation tools for healthcare professionals. Built with privacy-first architecture, it enables clinicians to conduct, track, and analyze patient mental health assessments.",
            "The platform leverages AI to identify patterns in patient responses, offering clinicians actionable insights for treatment planning. With secure cloud synchronization and offline capabilities, Psychosocial Analytics supports mental healthcare delivery across clinical and community settings.",
        ],
        "features": [
            "Comprehensive psychosocial assessment instruments",
            "AI-powered pattern recognition in patient responses",
            "Secure cloud-based patient data management",
            "Offline assessment capability for remote settings",
            "Progress tracking across treatment timeline",
            "Customizable assessment templates",
            "Clinical note integration and documentation",
            "Multi-patient dashboard with risk flagging",
            "HIPAA-compliant data encryption",
            "Export and reporting for clinical records",
            "Team collaboration for multi-provider care",
            "Integration with existing EHR systems",
        ],
        "audience": [
            "Clinical psychologists and therapists",
            "Psychiatrists and mental health nurses",
            "Social workers and counselors",
            "Community mental health organizations",
            "Hospital psychiatric departments",
            "Academic research institutions",
        ],
        "enterprise": {
            "individual": "admin assigned – Single clinician, up to 50 patients",
            "clinic": "admin assigned – Up to 10 clinicians, team dashboard",
            "institutional": "admin assigned – Unlimited clinicians, API access, custom instruments",
        },
        "investment": "The global mental health market is valued at $380B with telehealth growing at 25% CAGR. Psychosocial Analytics targets the $12B digital mental health assessment segment. With Yr1 projection of AU$20K and institutional sales pipeline, the platform offers strong growth in an expanding market.",
        "screens": [
            ("Dashboard", "Patient overview and risk flags"),
            ("Assessment", "Psychosocial evaluation interface"),
            ("Analytics", "AI-powered response pattern analysis"),
            ("Progress", "Treatment timeline tracking"),
            ("Patients", "Multi-patient management hub"),
            ("Templates", "Customizable assessment forms"),
            ("Reports", "Clinical documentation export"),
            ("Team", "Multi-clinician collaboration"),
            ("Settings", "Practice configuration"),
            ("Security", "Privacy and compliance center"),
        ],
    },
    {
        "name": "Ethereal Veil",
        "tagline": "Mindfulness & Meditation Wellness App",
        "category": "Health & Wellness",
        "testflight": "Available via invite (2 WCSS beta groups)",
        "appstore": "Coming Soon to App Store",
        "desc": [
            "Ethereal Veil is a beautifully crafted mindfulness and meditation application that guides users on a journey of inner peace and emotional wellness. With a stunning ethereal design aesthetic, the app combines guided meditations, breathing exercises, and ambient soundscapes.",
            "The app leverages AI to personalize meditation recommendations based on user mood, stress levels, and meditation history. Ethereal Veil creates a sanctuary of calm in an increasingly busy world, making mindfulness accessible to everyone.",
        ],
        "features": [
            "Guided meditation sessions for all experience levels",
            "AI-powered personalized meditation recommendations",
            "Breathing exercises with visual and haptic guidance",
            "Ambient soundscapes for focus and relaxation",
            "Mood tracking with emotional pattern insights",
            "Sleep stories and bedtime wind-down routines",
            "Mindfulness reminders and streak tracking",
            "Offline-downloadable meditation content",
            "Apple Health integration for mindfulness minutes",
            "Community challenges and group meditation",
            "Journaling with AI-powered reflection prompts",
            "Custom meditation timer with interval bells",
        ],
        "audience": [
            "Meditation beginners and experienced practitioners",
            "Individuals managing stress and anxiety",
            "Corporate wellness program participants",
            "Sleep quality improvement seekers",
            "Mental health self-care advocates",
            "Yoga and wellness community members",
        ],
        "enterprise": {
            "standard": "admin assigned – Full access, all meditations, AI recommendations",
            "annual": "admin assigned – 48% savings, advanced features",
            "lifetime": "administrator assigned – Unlimited lifetime access, all future updates",
        },
        "investment": "The global meditation and mindfulness market is projected at $9B by 2027, growing at 15% CAGR. Ethereal Veil targets the advanced meditation app segment with differentiated AI personalization. Yr1 projection of AU$15K with service access model scaling to AU$120K by Yr3.",
        "screens": [
            ("Home", "Personalized meditation dashboard"),
            ("Meditate", "Guided session player interface"),
            ("Breathing", "Animated breathing exercise guide"),
            ("Soundscapes", "Ambient audio mixer"),
            ("Mood", "Emotional tracking and insights"),
            ("Sleep", "Bedtime wind-down routines"),
            ("Journal", "AI-prompted reflection journal"),
            ("Progress", "Meditation statistics and streaks"),
            ("Profile", "User preferences and achievements"),
            ("Community", "Group challenges and sharing"),
        ],
    },
    {
        "name": "WCSLIB",
        "tagline": "Digital Library & Knowledge Management Platform",
        "category": "EdTech / Digital Resources",
        "testflight": "Available via invite (3 WCSS beta groups)",
        "appstore": "Coming Soon to App Store",
        "desc": [
            "WCSLIB is a comprehensive digital library and knowledge management platform that provides access to a vast collection of academic resources, research papers, and educational materials. Designed for students, researchers, and lifelong learners.",
            "The platform features AI-powered search and recommendation engines, personal reading lists, annotation tools, and collaborative study features. WCSLIB transforms how knowledge is discovered, organized, and shared in the digital age.",
        ],
        "features": [
            "Vast digital library with academic and research content",
            "AI-powered semantic search and recommendations",
            "Personal reading lists and collection organization",
            "In-app annotation and highlighting tools",
            "Collaborative study groups and discussion",
            "Citation management and bibliography generation",
            "Offline reading with sync across devices",
            "Accessibility features including text-to-speech",
            "Progress tracking across reading materials",
            "Integration with academic databases and APIs",
            "Digital rights management for institutional content",
            "Analytics dashboard for usage and engagement",
        ],
        "audience": [
            "University students and academic researchers",
            "Librarians and information specialists",
            "K-12 educators and curriculum developers",
            "Independent researchers and scholars",
            "Corporate learning and development teams",
            "Continuing education professionals",
        ],
        "enterprise": {
            "student": "admin assigned – Full access, personal library, annotation tools",
            "scholar": "admin assigned – Advanced research tools, API access, collaboration",
            "institutional": "admin assigned – Unlimited seats, custom branding, admin dashboard",
        },
        "investment": "The global digital library market is valued at $25B with 12% CAGR. WCSLIB targets the academic and institutional knowledge management segment. With Yr1 projection of AU$18K and strong institutional sales potential, the platform addresses a growing need for digital research infrastructure.",
        "screens": [
            ("Library", "Digital collection browser"),
            ("Search", "AI-powered semantic search"),
            ("Reader", "In-app reading and annotation"),
            ("Collections", "Personal reading lists"),
            ("Study Groups", "Collaborative discussion spaces"),
            ("Citations", "Citation management tools"),
            ("Offline", "Download management hub"),
            ("Analytics", "Reading progress dashboard"),
            ("Admin", "Institutional administration"),
            ("Profile", "Reader preferences and history"),
        ],
    },
    {
        "name": "WCS Platform",
        "tagline": "World Class Learning Management & Course Platform",
        "category": "EdTech / SaaS",
        "testflight": "Available via invite (4 beta groups: Internal Testers, WCS, WCSS)",
        "appstore": "Search 'WCS Platform' on App Store (Coming Soon)",
        "desc": [
            "WCS Platform is a comprehensive learning management system designed for the modern era of education. It combines course creation tools, AI-powered tutoring, community features, and blockchain-verified credentials in one seamless platform.",
            "Built for educators, institutions, and lifelong learners, WCS Platform supports everything from micro-credentials to full degree programs. The platform features a dark, immersive UI that keeps learners focused and engaged.",
        ],
        "features": [
            "Course creation studio with multimedia support",
            "AI-powered personalized learning paths",
            "Live virtual classroom with video conferencing",
            "Community forums and discussion groups",
            "Blockchain-verified digital credentials",
            "Progress tracking with learning analytics",
            "Assessment and quiz engine with AI grading",
            "Content marketplace for course creators",
            "Enterprise SSO and SCORM compliance",
            "Mobile-first responsive design",
            "Gamification and achievement system",
            "Multi-language support for global reach",
        ],
        "audience": [
            "Educational institutions and universities",
            "Corporate training departments",
            "Independent course creators and coaches",
            "Professional development providers",
            "Non-profit educational organizations",
            "Government training programs",
        ],
        "enterprise": {
            "creator": "admin assigned – Create up to 5 courses, basic analytics",
            "pro": "admin assigned – Unlimited courses, AI features, community",
            "enterprise": "admin assigned – White-label LMS, custom domain, dedicated support",
        },
        "investment": "The global LMS market is valued at $40B with 20% CAGR. WCS Platform's unique AI + Blockchain + Community trifecta differentiates it in a crowded market. Projected Yr1 revenue of AU$50K with path to AU$1M by Yr3 with institutional contracts.",
        "screens": [
            ("Dashboard", "Learning overview and activity feed"),
            ("Courses", "Course catalog and discovery"),
            ("Learning", "Interactive course player"),
            ("Community", "Discussion forums and groups"),
            ("AI Tutor", "AI-powered learning assistant"),
            ("Credentials", "Digital certificate wallet"),
            ("Analytics", "Learning progress analytics"),
            ("Marketplace", "Course creator marketplace"),
            ("Live Class", "Virtual classroom interface"),
            ("Profile", "Learner profile and achievements"),
        ],
    },
    {
        "name": "ScholarsGallery",
        "tagline": "AI-Powered Digital Art Gallery & Exhibition Platform",
        "category": "Creative / EdTech",
        "testflight": "Available via invite (3 beta groups: chrsappiah@gmail.com, christopher.appiahthompson@myworldclass.org, lako.julia@yahoo.com)",
        "appstore": "Search 'ScholarsGallery' on App Store (Coming Soon)",
        "desc": [
            "ScholarsGallery is a revolutionary AI-powered art exhibition platform that brings museum-quality digital galleries to iOS devices. Built with a Vapor backend and SwiftUI frontend, it enables artists, curators, and collectors to create, discover, and collect AI-assisted artwork.",
            "The platform features the innovative 'Dola' AI assistant that refines artistic prompts, a studio for AI art generation, and a full e-commerce engine for art editions. ScholarsGallery bridges the gap between traditional art curation and AI-generated creativity.",
        ],
        "features": [
            "Curated AI-powered art exhibitions and galleries",
            "AI Studio with Dola prompt refinement assistant",
            "Digital art generation with multiple artistic styles",
            "Built-in e-commerce for art edition sales",
            "Interactive 3D room browsing experiences",
            "Artist portfolio and discovery platform",
            "Scholarship and essay publication system",
            "Supabase-backed content management",
            "Secure admin portal checkout integration",
            "Admin panel for exhibition curation",
            "High-resolution artwork viewing",
            "Social sharing and community features",
        ],
        "audience": [
            "Digital artists and AI art creators",
            "Art collectors and investors",
            "Museum and gallery curators",
            "Art students and educators",
            "NFT and digital art enthusiasts",
            "Creative technology researchers",
        ],
        "enterprise": {
            "creator": "admin assigned – Publish up to 10 artworks, basic analytics",
            "gallery": "admin assigned – Unlimited exhibitions, Dola AI, full analytics",
            "institution": "admin assigned – White-label solution, API access, dedicated support",
        },
        "investment": "The AI art market is projected to reach $1.2B by 2027. ScholarsGallery's unique positioning at the intersection of AI creativity and traditional art curation makes it a compelling investment. With multiple revenue streams (commissions, service access, featured listings), Yr1 projection is AU$45K.",
        "screens": [
            ("Exhibitions", "Curated gallery exhibition browser"),
            ("Artwork Detail", "High-resolution artwork viewer"),
            ("AI Studio", "Dola-powered art generation studio"),
            ("Artist Profile", "Creator portfolio and collection"),
            ("Checkout", "Secure art edition access request flow"),
            ("Admin Panel", "Exhibition curation dashboard"),
            ("Scholarships", "Academic essay publications"),
            ("3D Gallery", "Immersive room browsing"),
            ("Collections", "Personal art collection manager"),
            ("Analytics", "Creator performance dashboard"),
        ],
    },
    {
        "name": "AgedCare Monitor",
        "tagline": "Non-Clinical Monitoring Aid for Aged Care",
        "category": "Healthcare / MedTech",
        "testflight": "Available via invite (3 beta groups: lako.julia@yahoo.com, chrsappiah@gmail.com, christopher.appiahthompson@myworldclass.org)",
        "appstore": "Live on App Store — v1.0.4 — Search 'AgedCare Monitor'",
        "desc": [
            "AgedCare Monitor is a non-clinical monitoring aid for professional carers, family carers, and aged-care facility staff supporting residents living with dementia, increased fall risk, or other care-intensive conditions.",
            "Core capabilities include on-device Vision fall detection using Apple Vision and CoreMotion — no video ever leaves the iPhone. Real-time audio distress-sound and keyword detection using SoundAnalysis and on-device Speech Recognition. Live resident room temperature via HomeKit-connected sensors and outdoor weather context via Open-Meteo.",
            "HealthKit integration for heart rate, blood oxygen and step-count trend observation (read-only). CloudKit private-database sync of incident records and an Apple Watch companion that surfaces alerts and SOS controls on the wrist. Multi-role dashboards: Administrator, Nurse, Carer and Family — each with a permission-scoped view.",
        ],
        "features": [
            "On-device Vision fall detection — no video leaves the device",
            "Real-time audio distress and keyword detection via SoundAnalysis",
            "HomeKit-connected room temperature monitoring",
            "HealthKit integration for vital sign trend observation",
            "CloudKit private-database sync for incident records",
            "Apple Watch companion with alerts and SOS controls",
            "Multi-role dashboards: Admin, Nurse, Carer, Family",
            "Live outdoor weather context via Open-Meteo",
            "On-device Speech Recognition for care keyword detection",
            "Privacy-first design — no analytics, no tracking, no advertising SDKs",
            "Account deletion via Settings with one tap",
            "Resident shell for bedside iPhone monitoring setup",
        ],
        "audience": [
            "Professional carers in aged care facilities",
            "Family carers supporting loved ones at home",
            "Aged care facility administrators and managers",
            "Dementia care specialists",
            "Nursing staff in residential care",
            "Home care package providers",
        ],
        "enterprise": {
            "facility": "admin assigned – Up to 20 residents, multi-role dashboard, alerts",
            "advanced": "admin assigned – Up to 100 residents, Apple Watch support, priority support",
            "enterprise": "admin assigned – Unlimited residents, dedicated server, API access, custom integration",
        },
        "investment": "The global aged care technology market exceeds $350B. AgedCare Monitor is already live on the App Store (v1.0.4, READY_FOR_SALE), making it the most mature app in the portfolio. With AU$35K Yr1 projection and strong differentiation through on-device AI privacy architecture, it represents the portfolio's flagship HealthTech asset.",
        "screens": [
            ("Dashboard", "Multi-role care overview dashboard"),
            ("Monitoring", "Resident monitoring with fall detection"),
            ("Alerts", "Real-time incident alert feed"),
            ("Audio", "Distress sound detection interface"),
            ("Health", "HealthKit vital signs trends"),
            ("Watch", "Apple Watch companion view"),
            ("Residents", "Resident management hub"),
            ("Temperature", "Room temperature monitoring"),
            ("Settings", "Facility configuration"),
            ("Privacy", "Privacy controls and data management"),
        ],
    },
]

# ─── Page Number Drawer ───
def add_page_number(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(DARK2)
    canvas.setStrokeColor(GOLD)
    canvas.setLineWidth(0.3)
    canvas.rect(20*mm, 10*mm, A4[0]-40*mm, 0.5)
    canvas.setFillColor(GRAY)
    canvas.setFont('Helvetica', 7)
    canvas.drawString(20*mm, 14*mm, "World Class Scholars Productions — Confidential Investment Portfolio")
    canvas.drawRightString(A4[0]-20*mm, 14*mm, f"Page {doc.page}")
    canvas.restoreState()

def first_page(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(DARK)
    canvas.rect(0, 0, A4[0], A4[1], fill=1, stroke=0)
    canvas.restoreState()

# ─── Document Build ───
def build_document():
    doc = SimpleDocTemplate(
        OUTPUT_PATH,
        pagesize=A4,
        leftMargin=20*mm,
        rightMargin=20*mm,
        topMargin=20*mm,
        bottomMargin=20*mm,
    )

    story = []
    W = A4[0] - 40*mm  # usable width

    # ── Cover Page ──
    story.append(Spacer(1, 100))
    story.append(Paragraph("WORLD CLASS SCHOLARS", ParagraphStyle('Cover1',
        fontSize=48, textColor=GOLD, fontName='Helvetica-Bold', alignment=TA_CENTER)))
    story.append(Paragraph("PRODUCTIONS", ParagraphStyle('Cover2',
        fontSize=42, textColor=WHITE, fontName='Helvetica-Bold', alignment=TA_CENTER,
        letterSpacing=8)))
    story.append(Spacer(1, 20))
    story.append(Paragraph("IOS APPLICATION PORTFOLIO", ParagraphStyle('Cover3',
        fontSize=18, textColor=GRAY, fontName='Helvetica', alignment=TA_CENTER,
        letterSpacing=4)))
    story.append(Spacer(1, 15))
    # Gold line
    d = Drawing(W, 2)
    d.add(Rect(0, 0, W, 2, fillColor=GOLD, strokeColor=None))
    story.append(d)
    story.append(Spacer(1, 15))
    story.append(Paragraph("8 Revolutionary iOS Applications", ParagraphStyle('Cover4',
        fontSize=22, textColor=HexColor("#E8C547"), fontName='Helvetica-Bold',
        alignment=TA_CENTER)))
    story.append(Spacer(1, 10))
    story.append(Paragraph("Transforming Healthcare, Education, Finance, Creative Arts & Social Justice", ParagraphStyle('Cover5',
        fontSize=12, textColor=GRAY, fontName='Helvetica', alignment=TA_CENTER)))
    story.append(Spacer(1, 40))

    # Contact box
    contact_data = [
        [Paragraph("<b>Dr. Christopher Appiah-Thompson</b>", ParagraphStyle('cn',
            fontSize=11, textColor=GOLD, fontName='Helvetica-Bold', alignment=TA_CENTER))],
        [Paragraph("Founder & Lead Developer, World Class Scholars", ParagraphStyle('cn2',
            fontSize=9, textColor=GRAY, fontName='Helvetica', alignment=TA_CENTER))],
        [Paragraph("christopher.appiahthompson@myworldclass.org  |  chrsappiah@gmail.com",
            ParagraphStyle('cn3', fontSize=8, textColor=GRAY, fontName='Helvetica',
                alignment=TA_CENTER))],
        [Paragraph("https://worldclassscholars.vercel.app",
            ParagraphStyle('cn4', fontSize=8, textColor=HexColor("#4A90D9"), fontName='Helvetica',
                alignment=TA_CENTER))],
    ]
    ct = Table(contact_data, colWidths=[W*0.7])
    ct.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), DARK2),
        ('BOX', (0,0), (-1,-1), 1, GOLD),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
    ]))
    story.append(ct)
    story.append(Spacer(1, 30))
    story.append(Paragraph("CONFIDENTIAL — FOR INVESTOR USE ONLY", ParagraphStyle('conf',
        fontSize=8, textColor=CRIMSON, fontName='Helvetica-Bold', alignment=TA_CENTER)))
    story.append(PageBreak())

    # ── Table of Contents ──
    story.append(Paragraph("TABLE OF CONTENTS", h1_style))
    story.append(Spacer(1, 10))
    toc_items = [
        "1. Executive Summary — The World Class Scholars Ecosystem",
        "2. Medlingo — AI Medical Terminology Learning Platform",
        "3. Carelens-Aged+ — Dementia & Aged Care Intelligence",
        "4. Psychosocial Analytics — Mental Health Assessment Platform",
        "5. Ethereal Veil — Mindfulness & Meditation Wellness",
        "6. WCSLIB — Digital Library & Knowledge Management",
        "7. WCS Platform — Learning Management System",
        "8. ScholarsGallery — AI Art Gallery & Exhibition Platform",
        "9. AgedCare Monitor — Non-Clinical Aged Care Monitoring",
        "10. Cross-Platform Technology Architecture",
        "11. Investment Opportunities & Revenue Projections",
        "12. Enterprise Access Models",
        "13. Go-to-Market Strategy",
        "14. Competitive Landscape Analysis",
        "15. Contact Information & Download Links",
    ]
    for item in toc_items:
        story.append(Paragraph(item, ParagraphStyle('toc', fontSize=10,
            textColor=GRAY, fontName='Helvetica', leading=22,
            leftIndent=10)))
    story.append(PageBreak())

    # ── Executive Summary ──
    story.append(Paragraph("EXECUTIVE SUMMARY", h1_style))
    story.append(Paragraph(
        "World Class Scholars Productions represents a new paradigm in iOS application development — "
        "where cutting-edge artificial intelligence meets human-centered design to solve real-world "
        "problems. Founded by Dr. Christopher Appiah-Thompson, the studio has produced eight "
        "distinct applications spanning healthcare, education, finance, creative arts, and gaming.",
        body_style))
    story.append(Paragraph(
        "Each application in the portfolio leverages AI and machine learning to deliver intelligent, "
        "personalized experiences that adapt to user needs. The common thread across all applications "
        "is a commitment to accessibility, social impact, and world-class user experience design.",
        body_style))
    story.append(Paragraph(
        "The combined addressable market across all eight applications exceeds $1.2 trillion USD, "
        "with the portfolio positioned to capture significant share in high-growth segments including "
        "HealthTech (CAGR 18%), EdTech (CAGR 20%), FinTech (CAGR 20%), and Gaming (CAGR 12%).",
        body_style))

    # Portfolio at a glance table
    story.append(Spacer(1, 10))
    story.append(Paragraph("PORTFOLIO AT A GLANCE", h2_style))
    glance_data = [["App", "Category", "Market", "Yr1 Projection"]]
    for app in APPS:
        proj = app.get("investment", "")
        yr1 = "AU$25K–AU$60K"
        if "AU$" in proj:
            import re
            m = re.search(r'AU\$\d+K', proj)
            if m:
                yr1 = m.group()
        glance_data.append([app["name"], app["category"], "Global", yr1])

    gt = Table(glance_data, colWidths=[W*0.25, W*0.3, W*0.15, W*0.2])
    gt.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
    ]))
    story.append(gt)
    story.append(PageBreak())

    # ── Individual App Sections ──
    for idx, app in enumerate(APPS):
        app_name = app["name"]
        screens = app.get("screens", [])

        # ════════════════════════════════════════════════════
        # PAGE 1: App Banner + Overview
        # ════════════════════════════════════════════════════
        story.append(banner(app_name, app["tagline"], width=W, height=90))
        story.append(Spacer(1, 15))
        story.append(Paragraph(f"APPLICATION OVERVIEW", h2_style))
        quick_paras = [
            f"{app_name} represents World Class Scholars' commitment to delivering "
            f"world-class iOS experiences that leverage artificial intelligence and "
            f"Apple's latest frameworks. This application addresses critical needs "
            f"in the {app['category'].split('/')[0].strip()} sector.",
            f"Built with SwiftUI, SwiftData, and CloudKit, {app_name} delivers a "
            f"seamless, responsive user experience across iPhone, iPad, and where "
            f"applicable, Apple Watch. The architecture prioritizes privacy, "
            f"offline capability, and real-time synchronization.",
        ]
        for p in quick_paras:
            story.append(Paragraph(p, body_style))
        story.append(Spacer(1, 6))

        # Quick info table
        info_data = [
            ["Category", app["category"]],
            ["Status", app.get("appstore", "TestFlight")],
            ["Distribution", app["testflight"]],
        ]
        info_t = Table(info_data, colWidths=[W*0.2, W*0.7])
        info_t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (0,-1), DARK2),
            ('BACKGROUND', (1,0), (1,-1), DARK),
            ('TEXTCOLOR', (0,0), (0,-1), GOLD),
            ('TEXTCOLOR', (1,0), (1,-1), GRAY),
            ('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,-1), 8),
            ('BOX', (0,0), (-1,-1), 0.5, GOLD),
            ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#444444")),
            ('TOPPADDING', (0,0), (-1,-1), 4),
            ('BOTTOMPADDING', (0,0), (-1,-1), 4),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ]))
        story.append(info_t)
        story.append(Spacer(1, 10))
        story.append(Paragraph(f"ABOUT {app_name.upper()}", h3_style))
        for para in app["desc"]:
            story.append(Paragraph(para, body_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 2-11: 10 Full-Page Screenshots
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — SCREENSHOT GALLERY", h1_style))
        story.append(Paragraph(
            f"The following pages showcase ten detailed mockups of {app_name}'s "
            f"core user interface screens. Each screenshot represents a key user "
            f"flow or feature within the application.",
            body_style))
        story.append(Spacer(1, 6))
        gallery_data = []
        for s_title, s_desc in screens:
            gallery_data.append([s_title, s_desc])
        gall_t = Table([["Screen", "Description"]] + gallery_data, colWidths=[W*0.3, W*0.6])
        gall_t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), GOLD),
            ('TEXTCOLOR', (0,0), (-1,0), BLACK),
            ('BACKGROUND', (0,1), (-1,-1), DARK2),
            ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,-1), 8),
            ('BOX', (0,0), (-1,-1), 0.5, GOLD),
            ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
            ('TOPPADDING', (0,0), (-1,-1), 4),
            ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ]))
        story.append(gall_t)
        story.append(PageBreak())

        for si, (s_title, s_desc) in enumerate(screens):
            extended_desc = (
                f"{s_desc}. This screen provides users with intuitive access to "
                f"core functionality, designed with accessibility and usability "
                f"as primary considerations. The interface follows Apple's Human "
                f"Interface Guidelines while maintaining the distinctive WCS design "
                f"language characterized by gold accents on dark backgrounds."
            )
            mockup = full_page_screenshot(s_title, extended_desc, si, app_name, width=W, height=680)
            story.append(Paragraph(f"{app_name.upper()} — {s_title.upper()}", h3_style))
            story.append(Paragraph(extended_desc, body_style))
            story.append(Spacer(1, 6))
            story.append(DrawingFlowable(mockup, width=W, height=680))
            story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGE 12-13: Key Features
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — KEY FEATURES", h1_style))
        story.append(Paragraph(
            f"{app_name} delivers a comprehensive feature set designed to meet "
            f"the needs of its target audience. The following features represent "
            f"the core capabilities that differentiate this application in the market.",
            body_style))
        story.append(Spacer(1, 6))
        story.append(feature_box("Core Features", app["features"], width=W))
        story.append(Spacer(1, 8))

        story.append(Paragraph("FEATURE HIGHLIGHTS & BENEFITS", h2_style))
        feat_benefits = [
            f"Each feature in {app_name} has been carefully designed and implemented "
            f"using Apple's latest frameworks including SwiftUI, SwiftData, and "
            f"CloudKit for seamless iCloud synchronization.",
            f"The AI-powered features leverage on-device Core ML models and server-side "
            f"machine learning through Vapor and Supabase integration, ensuring "
            f"intelligent, responsive user experiences.",
            f"Privacy and security are foundational: all user data is encrypted "
            f"at rest and in transit, with on-device processing prioritized "
            f"wherever possible to minimize data exposure.",
            f"Accessibility is built into every feature, with VoiceOver support, "
            f"Dynamic Type, and full keyboard navigation ensuring the app is "
            f"usable by everyone regardless of ability.",
        ]
        for fb in feat_benefits:
            story.append(Paragraph(f"• {fb}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGE 14: Target Audience
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — TARGET AUDIENCE", h1_style))
        story.append(Paragraph(
            f"The target audience for {app_name} spans multiple user segments, "
            f"each with specific needs that the application addresses through "
            f"tailored user experiences and feature sets.",
            body_style))
        story.append(Spacer(1, 6))
        story.append(feature_box("Primary User Segments", app["audience"], width=W))
        story.append(Spacer(1, 8))

        story.append(Paragraph("USER DEMOGRAPHICS & MARKET FIT", h2_style))
        demo_items = [
            f"The primary demographic spans professionals and consumers aged 18-65, "
            f"with specific segments varying by application category.",
            f"Enterprise users represent a significant growth opportunity, with "
            f"institutional contracts providing predictable recurring revenue.",
            f"The global addressable market across all segments exceeds $1 trillion, "
            f"with {app_name} positioned to capture share in its specific niche.",
            f"User acquisition strategy focuses on App Store optimization, "
            f"institutional partnerships, and targeted digital marketing campaigns.",
        ]
        for d in demo_items:
            story.append(Paragraph(f"• {d}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGE 15: Enterprise service access Tiers
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — service access TIERS", h1_style))
        story.append(Paragraph(
            f"{app_name} offers tiered service access plans designed to serve "
            f"users from individual consumers to large enterprise organizations. "
            f"Each tier provides increasing value and capabilities.",
            body_style))
        story.append(Spacer(1, 6))
        ent = app.get("enterprise", {})
        ent_data = []
        for tier, desc in ent.items():
            ent_data.append([tier.upper(), desc])
        ent_t = Table(ent_data, colWidths=[W*0.2, W*0.7])
        ent_t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (0,-1), DARK2),
            ('BACKGROUND', (1,0), (1,-1), DARK),
            ('TEXTCOLOR', (0,0), (0,-1), GOLD),
            ('TEXTCOLOR', (1,0), (1,-1), GRAY),
            ('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,-1), 8),
            ('BOX', (0,0), (-1,-1), 0.5, GOLD),
            ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#444444")),
            ('TOPPADDING', (0,0), (-1,-1), 4),
            ('BOTTOMPADDING', (0,0), (-1,-1), 4),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ]))
        story.append(ent_t)
        story.append(Spacer(1, 8))

        story.append(Paragraph("service access MODEL ADVANTAGES", h2_style))
        sub_adv = [
            "Recurring revenue model with predictable scheduled account administration cycles",
            "Tiered access settings enables natural expand path as user needs grow",
            "Enterprise contracts provide high-value, long-term revenue commitments",
            "free access review or open access tier drives user acquisition and conversion",
            "Annual service access discounts improve customer retention and reduce churn",
            "Institutional licensing opens B2B sales channels with multi-seat deployments",
        ]
        for sa in sub_adv:
            story.append(Paragraph(f"• {sa}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 16-17: Investment Opportunity
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — INVESTMENT OPPORTUNITY", h1_style))
        story.append(Paragraph(app.get("investment", ""), body_style))
        story.append(Spacer(1, 6))
        story.append(Paragraph("INVESTMENT HIGHLIGHTS", h2_style))
        inv_items = [
            "Scalable SaaS service access model with predictable recurring revenue",
            "Multi-platform iOS deployment with rapid Android portability",
            "AI-first architecture providing competitive differentiation",
            "Enterprise contract model with high switching costs",
            "Clear path to profitability within 18–24 months",
            "Proven founder with domain expertise and academic credentials",
        ]
        for item in inv_items:
            story.append(Paragraph(f"• {item}", bullet_style))
        story.append(Spacer(1, 8))

        story.append(Paragraph("GROWTH PROJECTIONS", h2_style))
        growth_items = [
            f"Year 1: Establish product-market fit through TestFlight beta program "
            f"with target of 500-1000 active beta users providing feedback.",
            f"Year 2: Public App Store launch with public rollout. Target 5,000-10,000 "
            f"downloads with 5-8% conversion to paid tiers.",
            f"Year 3: Enterprise sales expansion with target of 20-50 institutional "
            f"accounts. Expansion to international markets and Android platform.",
            f"Year 5: Portfolio-wide integration with cross-app data sharing and "
            f"unified WCS ecosystem. Target 100,000+ active users across portfolio.",
        ]
        for g in growth_items:
            story.append(Paragraph(f"• {g}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 18-19: Technical Architecture
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — TECHNICAL ARCHITECTURE", h1_style))
        story.append(Paragraph(
            f"{app_name} is built on a modern, scalable architecture that leverages "
            f"Apple's latest frameworks and industry best practices. The following "
            f"outlines the key technical decisions and architecture components.",
            body_style))
        story.append(Spacer(1, 6))

        arch_data = [
            ["Layer", "Technology", "Implementation"],
            ["UI Framework", "SwiftUI", "Declarative UI with MVVM architecture"],
            ["Data Persistence", "SwiftData + CloudKit", "Local storage with iCloud sync"],
            ["State Management", "SwiftUI @Observable", "Reactive state with Swift 6"],
            ["Networking", "URLSession + Async/Await", "Modern concurrency with Swift 6"],
            ["Authentication", "Sign in with Apple", "Privacy-preserving auth"],
            ["AI/ML", "Core ML + VN", "On-device machine learning inference"],
            ["Backend", "Vapor / Supabase", "Server-side Swift or PostgreSQL"],
            ["Analytics", "Custom Telemetry", "Privacy-focused usage analytics"],
            ["Access", "Admin-managed access", "administrator-managed access"],
            ["CI/CD", "Xcode Cloud + GitHub Actions", "Automated build and test pipeline"],
        ]
        arch_t = Table(arch_data, colWidths=[W*0.18, W*0.2, W*0.52])
        arch_t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), GOLD),
            ('TEXTCOLOR', (0,0), (-1,0), BLACK),
            ('BACKGROUND', (0,1), (-1,-1), DARK2),
            ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,-1), 7),
            ('BOX', (0,0), (-1,-1), 0.5, GOLD),
            ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ]))
        story.append(arch_t)
        story.append(Spacer(1, 8))

        story.append(Paragraph("ARCHITECTURE DECISIONS & RATIONALE", h2_style))
        arch_reasons = [
            "SwiftUI was chosen for its declarative syntax, performance, and "
            "seamless integration with Apple's ecosystem including Live Text, "
            "Widgets, and Swift Charts.",
            "SwiftData provides type-safe persistence with automatic CloudKit "
            "synchronization, eliminating the need for separate sync logic.",
            "On-device ML with Core ML ensures user privacy by processing "
            "sensitive data locally rather than sending to cloud servers.",
            "Vapor (Server-Side Swift) enables shared Swift types between "
            "client and server, reducing bugs and development time.",
        ]
        for ar in arch_reasons:
            story.append(Paragraph(f"• {ar}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 20-21: Market Analysis
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — MARKET ANALYSIS", h1_style))
        story.append(Paragraph(
            f"The market for {app_name} is substantial and growing. This analysis "
            f"examines the market size, growth trends, and positioning that make "
            f"this application a compelling investment opportunity.",
            body_style))
        story.append(Spacer(1, 6))

        market_sections = [
            ("MARKET SIZE & GROWTH",
             f"The global market addressed by {app_name} is valued in the billions "
             f"and growing at a compound annual growth rate of 12-20%. Digital "
             f"transformation across industries continues to accelerate demand for "
             f"well-designed mobile applications that solve real problems."),
            ("COMPETITIVE POSITIONING",
             f"{app_name} differentiates itself through its AI-first architecture, "
             f"privacy-preserving design, and integration with the Apple ecosystem. "
             f"Unlike competitors who rely on cloud processing, {app_name} performs "
             f"critical operations on-device, ensuring user privacy and offline capability."),
            ("ADDRESSABLE MARKET",
             f"The total addressable market spans multiple segments including direct "
             f"consumers, small-to-medium businesses, and large enterprise organizations. "
             f"Each segment represents a distinct revenue stream with different "
             f"acquisition costs and lifetime values."),
            ("GROWTH DRIVERS",
             f"Key growth drivers include increasing smartphone penetration, growing "
             f"awareness of digital health/education tools, enterprise digital "
             f"transformation initiatives, and the expanding App Store ecosystem."),
        ]
        for ms_title, ms_content in market_sections:
            story.append(Paragraph(ms_title, h2_style))
            story.append(Paragraph(ms_content, body_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 22-23: Competitive Landscape
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — COMPETITIVE LANDSCAPE", h1_style))
        story.append(Paragraph(
            f"A thorough analysis of the competitive landscape reveals that "
            f"{app_name} occupies a unique position in the market, with "
            f"differentiation across multiple dimensions.",
            body_style))
        story.append(Spacer(1, 6))

        comp_data = [
            ["Factor", app_name, "Competitor Avg", "Advantage"],
            ["AI Integration", "Deep AI/ML On-Device", "Basic or Cloud-Only", "Significant"],
            ["Privacy", "On-Device Processing", "Cloud Processing", "Strong"],
            ["Offline Support", "Full Offline Capability", "Limited or None", "Strong"],
            ["Apple Ecosystem", "Deep Integration", "Cross-Platform Focus", "Moderate"],
            ["Enterprise Features", "Comprehensive", "Varies Widely", "Strong"],
            ["access settings Model", "open access + service access", "Varied", "Competitive"],
            ["Accessibility", "VoiceOver + Dynamic Type", "Basic Support", "Strong"],
            ["UI/UX Design", "Gold/Dark advanced", "Standard", "Distinctive"],
        ]
        comp_t = Table(comp_data, colWidths=[W*0.2, W*0.28, W*0.28, W*0.14])
        comp_t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), GOLD),
            ('TEXTCOLOR', (0,0), (-1,0), BLACK),
            ('BACKGROUND', (0,1), (-1,-1), DARK2),
            ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,-1), 7),
            ('BOX', (0,0), (-1,-1), 0.5, GOLD),
            ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ]))
        story.append(comp_t)
        story.append(Spacer(1, 10))

        story.append(Paragraph("COMPETITIVE STRATEGY", h2_style))
        comp_strat = [
            f"{app_name} maintains competitive advantage through continuous "
            f"innovation in AI-powered features and deep Apple ecosystem integration.",
            f"The privacy-first architecture is a key differentiator as consumers "
            f"and enterprises increasingly prioritize data protection.",
            f"Enterprise-grade features including role-based access, audit logging, "
            f"and SSO integration provide a clear path to institutional sales.",
            f"The distinctive gold-on-dark design language creates brand recognition "
            f"and advanced positioning across all WCS applications.",
        ]
        for cs in comp_strat:
            story.append(Paragraph(f"• {cs}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 24-25: Roadmap & Milestones
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — ROADMAP & MILESTONES", h1_style))
        story.append(Paragraph(
            f"The development roadmap for {app_name} is structured across four "
            f"quarters, with clear milestones and deliverables for each phase.",
            body_style))
        story.append(Spacer(1, 6))

        roadmap_data = [
            ["Phase", "Timeline", "Key Deliverables"],
            ["Q1 Foundation", "Months 1-3",
             "Core architecture, data models, CI/CD pipeline, initial UI",
             ],
            ["Q2 Alpha", "Months 4-6",
             "Feature completion, TestFlight beta, user testing, iteration",
             ],
            ["Q3 Beta", "Months 7-9",
             "Public beta, performance optimization, localization, accessibility",
             ],
            ["Q4 Launch", "Months 10-12",
             "App Store release, marketing campaign, enterprise sales",
             ],
            ["Year 2", "Months 13-24",
             "Feature expansion, Android port, international markets, API platform",
             ],
            ["Year 3", "Months 25-36",
             "AI enhancement, ecosystem integration, scale enterprise sales",
             ],
        ]
        road_t = Table(roadmap_data, colWidths=[W*0.14, W*0.14, W*0.62])
        road_t.setStyle(TableStyle([
            ('BACKGROUND', (0,0), (-1,0), GOLD),
            ('TEXTCOLOR', (0,0), (-1,0), BLACK),
            ('BACKGROUND', (0,1), (-1,-1), DARK2),
            ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
            ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
            ('FONTSIZE', (0,0), (-1,-1), 7),
            ('BOX', (0,0), (-1,-1), 0.5, GOLD),
            ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ]))
        story.append(road_t)
        story.append(Spacer(1, 10))

        story.append(Paragraph("KEY MILESTONES", h2_style))
        milestones = [
            "TestFlight beta launch with 500+ active testers providing feedback",
            "App Store approval and launch with featured placement request",
            "First 1,000 downloads with 5% conversion rate to paid tiers",
            "First enterprise contract signed with multi-seat deployment",
            "Revenue milestone: AU$10K MRR within first 12 months of launch",
            "Expansion to international markets (US, UK, Canada, NZ, Singapore)",
        ]
        for m in milestones:
            story.append(Paragraph(f"• {m}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGES 26-27: Use Cases & User Personas
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — USE CASES & USER PERSONAS", h1_style))
        story.append(Paragraph(
            f"The following use cases and user personas illustrate how {app_name} "
            f"solves real problems for real users across different scenarios.",
            body_style))
        story.append(Spacer(1, 6))

        uc_titles = [
            "PRIMARY USE CASE",
            "SECONDARY USE CASE",
            "TERTIARY USE CASE",
        ]
        uc_descs = [
            f"Individual users leverage {app_name} for its core functionality, "
            f"accessing features through an intuitive interface designed for "
            f"efficiency and delight. The app adapts to user behavior through "
            f"AI-powered personalization.",
            f"Professional users in organizational settings use {app_name} to "
            f"collaborate with colleagues, manage shared resources, and access "
            f"enterprise features including analytics and reporting.",
            f"Enterprise administrators deploy {app_name} across their organization, "
            f"managing users, configuring permissions, and accessing compliance "
            f"and audit features through the admin dashboard.",
        ]
        for ut, ud in zip(uc_titles, uc_descs):
            story.append(Paragraph(ut, h2_style))
            story.append(Paragraph(ud, body_style))

        story.append(Spacer(1, 8))
        story.append(Paragraph("USER PERSONA EXAMPLES", h2_style))
        persona_items = [
            f"Individual User: Age 25-45, tech-savvy professional, values "
            f"design quality and privacy, willing to pay for advanced features.",
            f"Professional User: Age 30-60, domain expert in relevant field, "
            f"requires advanced features and collaboration tools for work.",
            f"Enterprise Decision Maker: IT manager or department head, "
            f"evaluates based on security, compliance, ROI, and support quality.",
        ]
        for pi in persona_items:
            story.append(Paragraph(f"• {pi}", bullet_style))
        story.append(PageBreak())

        # ════════════════════════════════════════════════════
        # PAGE 28: Section Summary
        # ════════════════════════════════════════════════════
        story.append(Paragraph(f"{app_name.upper()} — SECTION SUMMARY", h1_style))
        story.append(Paragraph(
            f"This section has presented a comprehensive overview of {app_name}, "
            f"covering its features, target market, technical architecture, "
            f"competitive positioning, and growth roadmap.",
            body_style))
        story.append(Spacer(1, 8))

        story.append(Paragraph("KEY TAKEAWAYS", h2_style))
        takeaways = [
            f"{app_name} addresses a significant market opportunity in the "
            f"{app['category']} sector with a differentiated AI-first approach.",
            f"The application is built on modern iOS technologies ensuring "
            f"performance, privacy, and scalability.",
            f"Multiple revenue streams including service access, enterprise "
            f"licensing, and role-gated access provide diversified income.",
            f"The development roadmap is clearly defined with measurable "
            f"milestones and realistic timelines.",
            f"Investment in {app_name} offers exposure to high-growth digital "
            f"markets with a proven development team and clear exit strategy.",
        ]
        for t in takeaways:
            story.append(Paragraph(f"• {t}", bullet_style))
        story.append(Spacer(1, 10))
        story.append(Paragraph(
            f"Proceed to the next section for detailed information on the "
            f"next application in the World Class Scholars portfolio.",
            ParagraphStyle('next_section', fontSize=10, textColor=HexColor("#E8C547"),
                fontName='Helvetica-Oblique', alignment=TA_CENTER, leading=14)))
        story.append(PageBreak())

    # ── Cross-Platform Architecture ──
    story.append(Paragraph("CROSS-PLATFORM TECHNOLOGY ARCHITECTURE", h1_style))
    story.append(Paragraph(
        "All eight applications in the World Class Scholars portfolio are built on a unified "
        "technology stack that prioritizes performance, security, and scalability. The architecture "
        "leverages Apple's latest frameworks including SwiftUI, SwiftData, and CloudKit while "
        "integrating with enterprise-grade backend services.",
        body_style))
    story.append(Spacer(1, 6))

    tech_data = [
        ["Layer", "Technology", "Purpose"],
        ["Frontend", "SwiftUI / SwiftData", "Modern declarative UI with persistent storage"],
        ["Frontend", "SpriteKit", "2D game engine for interactive experiences"],
        ["Backend", "Vapor (Server-Side Swift)", "Production API server framework"],
        ["Backend", "Supabase / PostgreSQL", "Real-time data and authentication"],
        ["Backend", "CloudKit", "iCloud-backed secure sync and storage"],
        ["Cloud", "Cloudflare Workers", "Edge computing and CDN"],
        ["AI/ML", "OpenAI API Integration", "AI-powered features and insights"],
        ["AI/ML", "Core ML / MLX", "On-device machine learning"],
        ["Access", "Admin-managed access / admin portal", "administrator-managed access"],
        ["DevOps", "GitHub Actions CI/CD", "Automated testing and deployment"],
        ["Analytics", "Custom Analytics Engine", "Usage metrics and insights"],
    ]
    tech_t = Table(tech_data, colWidths=[W*0.15, W*0.3, W*0.45])
    tech_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('ALIGN', (0,0), (-1,-1), 'LEFT'),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(tech_t)
    story.append(PageBreak())

    # ── Investment Opportunities ──
    story.append(Paragraph("INVESTMENT OPPORTUNITIES & REVENUE PROJECTIONS", h1_style))
    story.append(Paragraph(
        "World Class Scholars Productions is seeking strategic partners and investors to accelerate "
        "growth across the portfolio. The combined revenue potential across all eight applications "
        "represents a compelling investment opportunity in high-growth technology segments.",
        body_style))

    revenue_data = [
        ["Application", "Yr 1 Projection", "Yr 3 Projection", "Market Size"],
        ["Medlingo", "AU$30,000", "AU$200,000", "$80B Medical Ed"],
        ["Carelens-Aged+", "AU$25,000", "AU$250,000", "$350B Aged Care"],
        ["Psychosocial Analytics", "AU$20,000", "AU$180,000", "$380B Mental Health"],
        ["Ethereal Veil", "AU$15,000", "AU$120,000", "$9B Meditation"],
        ["WCSLIB", "AU$18,000", "AU$150,000", "$25B Digital Library"],
        ["WCS Platform", "AU$50,000", "AU$1,000,000", "$40B LMS"],
        ["ScholarsGallery", "AU$45,000", "AU$350,000", "$1.2B AI Art"],
        ["AgedCare Monitor", "AU$35,000", "AU$500,000", "$350B Aged Care"],
        ["TOTAL", "AU$238,000", "AU$2,750,000", ">$1.2 Trillion Combined"],
    ]
    rev_t = Table(revenue_data, colWidths=[W*0.2, W*0.2, W*0.2, W*0.3])
    rev_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (0,0), 'Helvetica-Bold'),
        ('FONTNAME', (-1,0), (-1,-1), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(rev_t)
    story.append(Spacer(1, 10))

    story.append(Paragraph("INVESTMENT PACKAGES", h2_style))
    inv_packages = [
        ["Angel Investment", "AU$50,000 – AU$150,000", "Equity stake in 2–3 apps, quarterly updates, advisory board seat"],
        ["Seed Round", "AU$250,000 – AU$500,000", "Portfolio-wide equity, board observer rights, strategic partnership"],
        ["Series A", "AU$1,000,000 – AU$3,000,000", "Majority portfolio equity, board seat, operational involvement"],
        ["Strategic Partnership", "Custom", "White-label licensing, co-development, market expansion partnership"],
    ]
    inv_t = Table(inv_packages, colWidths=[W*0.18, W*0.2, W*0.52])
    inv_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(inv_t)
    story.append(PageBreak())

    # ── Enterprise Access Models ──
    story.append(Paragraph("ENTERPRISE service access MODELS", h1_style))
    story.append(Paragraph(
        "All World Class Scholars applications offer tiered enterprise service access models designed "
        "to serve organizations of every size. From individual professionals to multinational "
        "institutions, our access settings scales with value delivery.",
        body_style))

    for app in APPS:
        story.append(Paragraph(f"<b>{app['name']}</b> — {app['tagline']}", h3_style))
        ent = app.get("enterprise", {})
        for tier, desc in ent.items():
            story.append(Paragraph(f"<b>{tier.upper()}:</b> {desc}", bullet_style))
        story.append(Spacer(1, 4))

    story.append(Spacer(1, 10))
    story.append(Paragraph("ENTERPRISE BENEFITS SUMMARY", h2_style))
    ent_benefits = [
        "Dedicated account manager and priority support",
        "Custom API integration and white-labeling options",
        "SLA guarantees with 99.9% uptime commitment",
        "Regular feature updates and roadmap influence",
        "Team training and onboarding assistance",
        "Advanced security and compliance features",
        "Custom reporting and analytics dashboards",
        "Multi-user administration and role-based access",
        "Data export and migration support",
        "Volume licensing discounts for 50+ seats",
    ]
    for benefit in ent_benefits:
        story.append(Paragraph(f"• {benefit}", bullet_style))
    story.append(PageBreak())

    # ── Go-to-Market Strategy ──
    story.append(Paragraph("GO-TO-MARKET STRATEGY", h1_style))
    story.append(Paragraph(
        "World Class Scholars employs a multi-channel go-to-market strategy that leverages both "
        "digital and traditional channels to maximize reach and adoption across all eight applications.",
        body_style))

    strategy_items = [
        ("App Store Optimization", "Leveraging ASO best practices for organic discovery across all 8 applications"),
        ("Social Media Marketing", "Targeted campaigns on LinkedIn, Twitter/X, Threads, and Instagram"),
        ("Content Marketing", "Educational content, blog posts, and video tutorials demonstrating app value"),
        ("Institutional Partnerships", "Direct B2B sales to healthcare facilities, schools, and financial institutions"),
        ("TestFlight Beta Program", "Building communities of early adopters who provide feedback and testimonials"),
        ("University Collaborations", "Research partnerships and academic licensing for education apps"),
        ("Enterprise Sales Team", "Dedicated sales outreach to mid-market and enterprise prospects"),
        ("open access Conversion", "Free tiers with advanced expands driving conversion funnel"),
        ("Referral Programs", "User referral incentives driving viral growth"),
        ("Conference & Events", "Demonstrations at healthcare, education, and technology conferences"),
    ]

    gtm_data = [["Channel", "Strategy"]]
    for ch, st in strategy_items:
        gtm_data.append([ch, st])
    gtm_t = Table(gtm_data, colWidths=[W*0.25, W*0.65])
    gtm_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(gtm_t)
    story.append(PageBreak())

    # ── Competitive Landscape ──
    story.append(Paragraph("COMPETITIVE LANDSCAPE ANALYSIS", h1_style))
    comp_data = [
        ["App", "Category", "Key Competitors", "WCS Advantage"],
        ["Medlingo", "Medical Education", "Anki, UWorld, Sketchy", "AI Avatar Tutor, spaced repetition"],
        ["Carelens-Aged+", "Aged Care", "CareLen, NurseWatch", "Biospychosocial AI, NeuroWatch"],
        ["Psychosocial Analytics", "Mental Health", "TherapyNotes, SimplePractice", "AI pattern recognition, offline"],
        ["Ethereal Veil", "Wellness", "Calm, Headspace", "AI personalization, unique aesthetic"],
        ["WCSLIB", "Digital Library", "Libby, OverDrive", "AI search, annotation tools"],
        ["WCS Platform", "LMS", "Canvas, Moodle, Teachable", "AI + Blockchain + Community"],
        ["ScholarsGallery", "Creative Tech", "Artsy, Saatchi Art", "Dola AI generation, 3D rooms"],
        ["AgedCare Monitor", "Aged Care Tech", "NurseWatch, SilverChain", "On-device AI, privacy-first"],
    ]
    comp_t = Table(comp_data, colWidths=[W*0.11, W*0.18, W*0.23, W*0.38])
    comp_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTNAME', (-1,-1), (-1,-1), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 7),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(comp_t)
    story.append(PageBreak())

    # ── Contact & Download ──
    story.append(Paragraph("CONTACT INFORMATION & DOWNLOAD LINKS", h1_style))
    story.append(Paragraph(
        "We invite you to explore our portfolio and join us in building world-class applications "
        "that make a difference. Download our apps today and become part of the World Class "
        "Scholars community.",
        body_style))
    story.append(Spacer(1, 15))

    download_links = [
        ["Medlingo", "Email for TestFlight invite (2 beta groups active)"],
        ["Carelens-Aged+", "Email for TestFlight invite (2 beta groups active)"],
        ["Psychosocial Analytics", "Email for TestFlight invite (Internal Testers)"],
        ["Ethereal Veil", "Email for TestFlight invite (WCSS beta groups)"],
        ["WCSLIB", "Email for TestFlight invite (WCSS beta groups)"],
        ["WCS Platform", "Email for TestFlight invite (4 beta groups active)"],
        ["ScholarsGallery", "Email for TestFlight invite (3 beta groups active)"],
        ["AgedCare Monitor", "Live on App Store — v1.0.4 — Search 'AgedCare Monitor'"],
    ]
    dl_data = [["Application", "Download Link"]]
    for name, link in download_links:
        dl_data.append([name, link])

    dl_t = Table(dl_data, colWidths=[W*0.3, W*0.6])
    dl_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), GOLD),
        ('TEXTCOLOR', (0,0), (-1,0), BLACK),
        ('BACKGROUND', (0,1), (-1,-1), DARK2),
        ('TEXTCOLOR', (0,1), (-1,-1), WHITE),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('BOX', (0,0), (-1,-1), 0.5, GOLD),
        ('INNERGRID', (0,0), (-1,-1), 0.3, HexColor("#555555")),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
    ]))
    story.append(dl_t)
    story.append(Spacer(1, 20))

    # Contact card
    story.append(Paragraph("CONTACT DETAILS", h2_style))
    contact_items = [
        ("Founder & Lead Developer", "Dr. Christopher Appiah-Thompson"),
        ("Email (Primary)", "christopher.appiahthompson@myworldclass.org"),
        ("Email (Secondary)", "chrsappiah@gmail.com"),
        ("Website", "https://worldclassscholars.vercel.app"),
        ("Location", "Newcastle, Australia"),
        ("Profiles", "LinkedIn: /in/christopher-appiah-thompson-a2014045"),
    ]
    for label, value in contact_items:
        story.append(Paragraph(f"<b>{label}:</b>  {value}", ParagraphStyle('ci',
            fontSize=9, textColor=GRAY, fontName='Helvetica', leading=16,
            leftIndent=10)))

    story.append(Spacer(1, 20))
    story.append(Paragraph(
        "<i>For investment inquiries, partnership opportunities, or enterprise licensing, "
        "please reach out via email. We look forward to building the future together.</i>",
        ParagraphStyle('closing', fontSize=10, textColor=HexColor("#E8C547"),
            fontName='Helvetica-Oblique', alignment=TA_CENTER, leading=14)))
    story.append(Spacer(1, 10))
    story.append(Paragraph("WORLD CLASS SCHOLARS PRODUCTIONS", ParagraphStyle('fin',
        fontSize=16, textColor=GOLD, fontName='Helvetica-Bold', alignment=TA_CENTER)))
    story.append(Spacer(1, 5))
    story.append(Paragraph("Transforming Lives Through World-Class Technology", ParagraphStyle('fin2',
        fontSize=10, textColor=GRAY, fontName='Helvetica', alignment=TA_CENTER)))

    # ── Build ──
    doc.build(story, onFirstPage=first_page, onLaterPages=add_page_number)
    return OUTPUT_PATH

if __name__ == "__main__":
    path = build_document()
    print(f"PDF generated: {path}")
