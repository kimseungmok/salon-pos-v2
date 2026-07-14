#!/usr/bin/env python3
"""
scripts/build_worldmap.py — Salon POS v2 Dashboard Builder

docs/ 폴더의 모든 .md 파일을 읽어 WORLD_MAP.html에 임베드한다.
생성된 파일은 file:// 및 HTTP 서버 양쪽에서 동작한다.

사용법:
    python3 scripts/build_worldmap.py
"""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).parent.parent
DOCS_DIR = ROOT / 'docs'
LIB_DIR = ROOT / 'lib'
OUTPUT = DOCS_DIR / 'WORLD_MAP.html'


def gather_docs():
    docs = {}
    for path in sorted(DOCS_DIR.rglob('*.md')):
        rel = str(path.relative_to(DOCS_DIR)).replace('\\', '/')
        try:
            docs[rel] = path.read_text(encoding='utf-8')
        except Exception as e:
            print(f'  [skip] {rel}: {e}')
    return docs


def git_stats():
    try:
        commits = subprocess.check_output(
            ['git', '-C', str(ROOT), 'rev-list', '--count', 'HEAD'],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
    except Exception:
        commits = '?'
    dart_files = len(list(LIB_DIR.rglob('*.dart'))) if LIB_DIR.exists() else '?'
    return commits, dart_files


# ── HTML Template ─────────────────────────────────────────────────────────────

TEMPLATE = """\
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Salon POS v2 — Dashboard</title>
<style>
/* ── Reset ── */
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
button,input,textarea,select{font:inherit}

/* ── Tokens ── */
:root {
  --bg:      #050D1A;
  --surf:    #0C1A2E;
  --surf-hi: #112240;
  --surf-hh: #172D52;
  --border:  #1A3655;
  --bord-hi: #2A5A8A;
  --gold:    #F0C040;
  --gold-d:  rgba(240,192,64,.14);
  --gold-g:  rgba(240,192,64,.28);
  --ok:      #34D399;
  --ok-bg:   rgba(52,211,153,.09);
  --warn:    #FBBF24;
  --warn-bg: rgba(251,191,36,.09);
  --info:    #60A5FA;
  --info-bg: rgba(96,165,250,.09);
  --skip:    #4B5563;
  --skip-bg: rgba(75,85,99,.16);
  --text:    #E2E8F0;
  --muted:   #64748B;
  --dim:     #1D2E47;
  --font: system-ui,-apple-system,sans-serif;
  --mono: ui-monospace,'SF Mono','Cascadia Mono',monospace;
  --r: 7px;
}
@media (prefers-color-scheme:light){:root{
  --bg:#EEF2F7;--surf:#FFF;--surf-hi:#E8F0FA;--surf-hh:#D8E8F4;
  --border:#C9D8ED;--bord-hi:#90B4E0;
  --gold:#B8860B;--gold-d:rgba(184,134,11,.1);--gold-g:rgba(184,134,11,.2);
  --skip:#94A3B8;--skip-bg:rgba(148,163,184,.15);
  --text:#0F172A;--muted:#64748B;--dim:#E2E8F0;
}}
:root[data-theme="light"]{
  --bg:#EEF2F7;--surf:#FFF;--surf-hi:#E8F0FA;--surf-hh:#D8E8F4;
  --border:#C9D8ED;--bord-hi:#90B4E0;
  --gold:#B8860B;--gold-d:rgba(184,134,11,.1);--gold-g:rgba(184,134,11,.2);
  --skip:#94A3B8;--skip-bg:rgba(148,163,184,.15);
  --text:#0F172A;--muted:#64748B;--dim:#E2E8F0;
}
:root[data-theme="dark"]{
  --bg:#050D1A;--surf:#0C1A2E;--surf-hi:#112240;--surf-hh:#172D52;
  --border:#1A3655;--bord-hi:#2A5A8A;
  --gold:#F0C040;--gold-d:rgba(240,192,64,.14);--gold-g:rgba(240,192,64,.28);
  --skip:#4B5563;--skip-bg:rgba(75,85,99,.16);
  --text:#E2E8F0;--muted:#64748B;--dim:#1D2E47;
}

/* ── App shell ── */
html,body{height:100%}
body{font-family:var(--font);background:var(--bg);color:var(--text);display:flex;flex-direction:column;overflow:hidden}

/* ── Header ── */
.app-hdr{display:flex;align-items:center;background:var(--surf);border-bottom:1px solid var(--border);padding:0 16px;flex-shrink:0;user-select:none;min-height:44px}
.app-brand{font-family:var(--mono);font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--gold);margin-right:20px;white-space:nowrap}
.tab-nav{display:flex;gap:2px;flex:1}
.tab-btn{background:none;border:1px solid transparent;border-radius:var(--r);padding:5px 14px;font-size:13px;color:var(--muted);cursor:pointer;transition:color .12s,background .12s;white-space:nowrap}
.tab-btn:hover{color:var(--text);background:var(--surf-hi)}
.tab-btn.active{color:var(--text);background:var(--surf-hi);border-color:var(--border)}
.theme-btn{margin-left:auto;background:none;border:none;font-size:15px;cursor:pointer;padding:5px 7px;border-radius:var(--r);color:var(--muted);transition:color .12s}
.theme-btn:hover{color:var(--text)}

/* ── Tab panels ── */
.tab-panel{display:none;flex:1;overflow:hidden}
.tab-panel.active{display:flex;flex-direction:column}
#tab-docs.active,#tab-memos.active{flex-direction:row}

/* ── MAP TAB ── */
#tab-map{
  overflow-y:auto;padding:20px 16px 40px;
  background-image:linear-gradient(var(--dim) 1px,transparent 1px),linear-gradient(90deg,var(--dim) 1px,transparent 1px);
  background-size:28px 28px;
}
.stats{display:flex;gap:1px;background:var(--border);border:1px solid var(--border);border-radius:var(--r);overflow:hidden;margin-bottom:18px}
.stat{flex:1;background:var(--surf);padding:11px 0;text-align:center}
.stat-v{font-family:var(--mono);font-size:19px;font-weight:700;font-variant-numeric:tabular-nums;line-height:1}
.stat-l{font-size:10px;color:var(--muted);margin-top:3px}
.map-sec{font-family:var(--mono);font-size:10px;letter-spacing:.2em;text-transform:uppercase;color:var(--muted);margin:20px 0 9px;display:flex;align-items:center;gap:10px}
.map-sec::after{content:'';flex:1;height:1px;background:var(--border)}
.card{background:var(--surf);border:1px solid var(--border);border-radius:var(--r);padding:13px;position:relative}
@keyframes pulse{0%,100%{box-shadow:0 0 0 1px var(--gold),0 0 12px var(--gold-d)}50%{box-shadow:0 0 0 1px var(--gold),0 0 26px var(--gold-g)}}
.card.cur{border-color:var(--gold);animation:pulse 2.4s ease-in-out infinite}
.here{position:absolute;top:-10px;left:11px;background:var(--gold);color:#000;font-family:var(--mono);font-size:9px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;padding:2px 8px;border-radius:10px}
.ch{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:9px}
.c-name{font-size:13px;font-weight:600;line-height:1.2}
.c-en{font-size:10px;color:var(--muted);font-family:var(--mono);margin-top:2px}
.c-pct{font-family:var(--mono);font-size:19px;font-weight:700;font-variant-numeric:tabular-nums;line-height:1;text-align:right}
.c-pct-u{font-size:10px;color:var(--muted)}
.sr{display:flex;align-items:center;gap:6px;margin-bottom:4px}
.sr-l{font-family:var(--mono);font-size:9px;letter-spacing:.06em;text-transform:uppercase;color:var(--muted);width:38px;flex-shrink:0}
.sr-bar{flex:1;height:3px;background:var(--skip-bg);border-radius:2px;overflow:hidden}
.sr-fill{height:100%;border-radius:2px}
.sr-pip{font-size:9px;font-family:var(--mono);padding:2px 6px;border-radius:3px;white-space:nowrap;flex-shrink:0}
.s-ok .sr-fill{background:var(--ok);width:100%}.s-ok .sr-pip{background:var(--ok-bg);color:var(--ok)}
.s-pt .sr-fill{background:var(--warn);width:55%}.s-pt .sr-pip{background:var(--warn-bg);color:var(--warn)}
.s-sk .sr-fill{background:var(--info);width:22%}.s-sk .sr-pip{background:var(--info-bg);color:var(--info)}
.s-no .sr-fill{width:0}.s-no .sr-pip{background:var(--skip-bg);color:var(--muted)}
.prog-bar{height:3px;background:var(--border);border-radius:2px;overflow:hidden;margin-top:9px}
.prog-fill{height:100%;border-radius:2px;background:linear-gradient(90deg,var(--ok),rgba(52,211,153,.4))}
.c-note{font-size:10px;color:var(--muted);margin-top:6px;line-height:1.5}
.g3{display:grid;grid-template-columns:repeat(3,1fr);gap:9px}
.g4{display:grid;grid-template-columns:repeat(4,1fr);gap:9px}
.pipe{display:grid;grid-template-columns:1fr auto 1fr auto 1fr;align-items:stretch;gap:0}
.pipe-arr{display:flex;align-items:center;padding:0 9px;color:var(--bord-hi);font-size:16px;user-select:none}
.legend{display:flex;flex-wrap:wrap;gap:12px;margin-bottom:16px}
.leg{display:flex;align-items:center;gap:5px;font-family:var(--mono);font-size:11px;color:var(--muted)}
.leg-d{width:8px;height:8px;border-radius:2px;flex-shrink:0}
.pri-strip{background:var(--surf);border:1px solid var(--border);border-radius:var(--r);padding:13px 15px;margin-top:9px}
.pri-ttl{font-family:var(--mono);font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--gold);margin-bottom:9px}
.pri-list{display:flex;gap:7px;flex-wrap:wrap}
.pri-item{display:flex;align-items:center;gap:9px;background:var(--surf-hi);border:1px solid var(--border);border-radius:6px;padding:8px 11px;flex:1;min-width:150px}
.pri-n{font-family:var(--mono);font-size:19px;font-weight:700;font-variant-numeric:tabular-nums;color:var(--dim);line-height:1;flex-shrink:0}
.pri-n.now{color:var(--gold)}
.pri-nm{font-size:12px;font-weight:600}
.pri-d{font-size:11px;color:var(--muted);margin-top:2px}
.issues{display:flex;flex-wrap:wrap;gap:5px;margin-top:9px}
.ic{font-family:var(--mono);font-size:10px;background:var(--skip-bg);color:var(--muted);border:1px solid var(--border);padding:3px 8px;border-radius:10px}
.ic.w{background:var(--warn-bg);color:var(--warn);border-color:rgba(251,191,36,.2)}

/* ── DOCS TAB ── */
.doc-sidebar{width:230px;flex-shrink:0;border-right:1px solid var(--border);display:flex;flex-direction:column;overflow:hidden}
.doc-search-wrap{padding:9px;border-bottom:1px solid var(--border)}
.doc-search{width:100%;background:var(--surf-hi);border:1px solid var(--border);border-radius:var(--r);padding:6px 10px;font-size:12px;color:var(--text);outline:none}
.doc-search:focus{border-color:var(--bord-hi)}
.doc-list{flex:1;overflow-y:auto;padding:4px 0}
.doc-grp-hdr{font-family:var(--mono);font-size:9px;letter-spacing:.15em;text-transform:uppercase;color:var(--muted);padding:8px 11px 3px;margin-top:3px}
.doc-item{display:block;width:100%;background:none;border:none;text-align:left;padding:5px 11px;cursor:pointer;font-size:12px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;transition:background .1s,color .1s}
.doc-item:hover{background:var(--surf-hi);color:var(--text)}
.doc-item.active{background:var(--surf-hh);color:var(--gold)}
.doc-pane{flex:1;overflow-y:auto}
.doc-placeholder{height:100%;display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:13px;font-family:var(--mono)}
.doc-content{padding:26px 34px;max-width:820px}
.doc-path{font-family:var(--mono);font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:var(--muted);margin-bottom:14px;padding-bottom:9px;border-bottom:1px solid var(--border)}

/* ── LOG TAB ── */
#tab-log{overflow-y:auto}
.log-inner{padding:26px 34px;max-width:820px}
.log-hdr{font-family:var(--mono);font-size:10px;letter-spacing:.15em;text-transform:uppercase;color:var(--muted);margin-bottom:14px;padding-bottom:9px;border-bottom:1px solid var(--border)}

/* ── MEMOS TAB ── */
.memo-sidebar{width:210px;flex-shrink:0;border-right:1px solid var(--border);display:flex;flex-direction:column;overflow:hidden}
.memo-new-btn{margin:9px;background:var(--surf-hi);border:1px solid var(--border);border-radius:var(--r);padding:7px;font-size:12px;font-weight:600;color:var(--gold);cursor:pointer;text-align:center;transition:background .12s}
.memo-new-btn:hover{background:var(--surf-hh)}
.memo-list{flex:1;overflow-y:auto}
.memo-item{display:block;width:100%;background:none;border:none;border-bottom:1px solid var(--border);text-align:left;padding:9px 11px;cursor:pointer;transition:background .1s}
.memo-item:hover{background:var(--surf-hi)}
.memo-item.active{background:var(--surf-hh)}
.memo-item-title{font-size:12px;font-weight:600;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.memo-item-date{font-size:10px;color:var(--muted);font-family:var(--mono);margin-top:2px}
.memo-editor-area{flex:1;display:flex;flex-direction:column;overflow:hidden}
.memo-placeholder{flex:1;display:flex;align-items:center;justify-content:center;color:var(--muted);font-size:13px;font-family:var(--mono)}
.memo-editor{flex:1;display:flex;flex-direction:column}
.memo-title-input{background:none;border:none;border-bottom:1px solid var(--border);padding:14px 18px;font-size:16px;font-weight:600;color:var(--text);outline:none}
.memo-title-input::placeholder{color:var(--muted);font-weight:400}
.memo-body-input{flex:1;background:none;border:none;padding:14px 18px;font-size:13px;color:var(--text);outline:none;resize:none;line-height:1.75}
.memo-body-input::placeholder{color:var(--muted)}
.memo-footer{padding:10px 18px;border-top:1px solid var(--border);display:flex;gap:7px;align-items:center}
.memo-date{font-family:var(--mono);font-size:10px;color:var(--muted);margin-left:auto}
.btn{background:var(--surf-hi);border:1px solid var(--border);border-radius:var(--r);padding:5px 13px;font-size:12px;color:var(--text);cursor:pointer;transition:background .12s}
.btn:hover{background:var(--surf-hh)}
.btn.danger{color:#F87171}.btn.danger:hover{background:rgba(248,113,113,.1)}
.btn.primary{border-color:var(--gold);color:var(--gold)}.btn.primary:hover{background:var(--gold-d)}

/* ── Markdown ── */
.md h1{font-size:20px;font-weight:700;margin:18px 0 9px;letter-spacing:-.01em}
.md h2{font-size:16px;font-weight:600;margin:16px 0 7px;padding-bottom:4px;border-bottom:1px solid var(--border)}
.md h3{font-size:14px;font-weight:600;margin:13px 0 5px}
.md h4,.md h5,.md h6{font-size:13px;font-weight:600;margin:11px 0 4px;color:var(--muted)}
.md p{margin:6px 0;line-height:1.75;font-size:13px}
.md strong{font-weight:600}
.md em{font-style:italic}
.md a{color:var(--info);text-decoration:none}
.md a:hover{text-decoration:underline}
.md code{font-family:var(--mono);font-size:11px;background:var(--surf-hi);padding:1px 5px;border-radius:3px}
.md pre{background:var(--surf-hi);border:1px solid var(--border);border-radius:6px;padding:13px 15px;overflow-x:auto;margin:9px 0}
.md pre code{background:none;padding:0;font-size:12px;line-height:1.6}
.md .tw{overflow-x:auto;margin:9px 0}
.md table{border-collapse:collapse;font-size:12px;min-width:360px}
.md th,.md td{border:1px solid var(--border);padding:5px 9px;text-align:left;vertical-align:top}
.md th{background:var(--surf-hi);font-weight:600}
.md tr:nth-child(even) td{background:rgba(255,255,255,.02)}
.md blockquote{border-left:3px solid var(--gold);padding:5px 13px;background:var(--surf-hi);margin:9px 0;color:var(--muted);font-size:13px}
.md hr{border:none;border-top:1px solid var(--border);margin:16px 0}
.md ul,.md ol{padding-left:20px;margin:7px 0}
.md li{margin:3px 0;line-height:1.65;font-size:13px}

/* ── Scrollbar ── */
::-webkit-scrollbar{width:5px;height:5px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px}
::-webkit-scrollbar-thumb:hover{background:var(--bord-hi)}

@media(max-width:700px){
  .g3,.g4{grid-template-columns:1fr 1fr}
  .pipe{grid-template-columns:1fr}
  .pipe-arr{display:none}
  .doc-sidebar,.memo-sidebar{width:150px}
  .app-brand{display:none}
}
</style>
</head>
<body>

<!-- Header -->
<header class="app-hdr">
  <div class="app-brand">&#9656; salon-pos-v2</div>
  <nav class="tab-nav">
    <button class="tab-btn active" onclick="showTab('map',this)">&#128506; 월드맵</button>
    <button class="tab-btn" onclick="showTab('docs',this)">&#128196; 문서</button>
    <button class="tab-btn" onclick="showTab('log',this)">&#128203; 작업로그</button>
    <button class="tab-btn" onclick="showTab('memos',this)">&#9998; 메모</button>
  </nav>
  <button class="theme-btn" onclick="toggleTheme()" title="테마 전환">&#127763;</button>
</header>

<!-- ════════════════ MAP TAB ════════════════ -->
<section id="tab-map" class="tab-panel active">

<div class="legend">
  <div class="leg"><div class="leg-d" style="background:var(--ok)"></div>완료</div>
  <div class="leg"><div class="leg-d" style="background:var(--warn)"></div>일부완료</div>
  <div class="leg"><div class="leg-d" style="background:var(--info)"></div>골격(UI)</div>
  <div class="leg"><div class="leg-d" style="background:var(--skip)"></div>미시작</div>
</div>

<div class="stats">
  <div class="stat"><div class="stat-v" id="statCommits">__COMMITS__</div><div class="stat-l">Commits</div></div>
  <div class="stat"><div class="stat-v" id="statDart">__DART_FILES__</div><div class="stat-l">Dart 파일</div></div>
  <div class="stat"><div class="stat-v">372</div><div class="stat-l">테스트 통과</div></div>
  <div class="stat"><div class="stat-v" style="color:var(--ok);font-size:13px">M1&#183;M2&#183;M3</div><div class="stat-l">완료 Milestone</div></div>
  <div class="stat"><div class="stat-v" style="color:var(--warn)">~30%</div><div class="stat-l">전체 진행률</div></div>
</div>

<div class="map-sec">핵심 POS 파이프라인</div>
<div class="pipe">
  <div class="card cur">
    <div class="here">&#128205; 현재 위치</div>
    <div class="ch">
      <div><div class="c-name">예약</div><div class="c-en">Booking</div></div>
      <div><div class="c-pct">75</div><div class="c-pct-u">%</div></div>
    </div>
    <div class="sr s-ok"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">완료</div></div>
    <div class="sr s-pt"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">일부</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:75%"></div></div>
    <div class="c-note">BookingCompletionCaller &#183; Future.wait() &#183; getBookingById()<br>&#9888; E2E 미연결 &#183; CC-1/CC-2 미결</div>
  </div>
  <div class="pipe-arr">&#8594;</div>
  <div class="card">
    <div class="ch">
      <div><div class="c-name">세션 / 결제</div><div class="c-en">Session &amp; POS</div></div>
      <div><div class="c-pct">50</div><div class="c-pct-u">%</div></div>
    </div>
    <div class="sr s-ok"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">완료</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:50%"></div></div>
    <div class="c-note">SessionClosingWorkflow &#183; Conditional UPDATE<br>&#9888; pos_order_screen 골격 &#183; 결제 흐름 미연결</div>
  </div>
  <div class="pipe-arr">&#8594;</div>
  <div class="card">
    <div class="ch">
      <div><div class="c-name">매출 리포트</div><div class="c-en">Sales Report</div></div>
      <div><div class="c-pct">5</div><div class="c-pct-u">%</div></div>
    </div>
    <div class="sr s-no"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">미시작</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:5%"></div></div>
    <div class="c-note">집계 로직 미구현<br>sales_report_screen 골격만</div>
  </div>
</div>

<div class="map-sec">계산 엔진 레이어</div>
<div class="g3">
  <div class="card">
    <div class="ch"><div><div class="c-name">가격 정책</div><div class="c-en">Pricing</div></div><div><div class="c-pct" style="font-size:16px">35</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-ok"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">완료</div></div>
    <div class="sr s-no"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">미시작</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:35%"></div></div>
    <div class="c-note">PricingEngine (순수계산) &#183; ADR-001<br>관리 화면 없음</div>
  </div>
  <div class="card">
    <div class="ch"><div><div class="c-name">프로모션</div><div class="c-en">Promotion</div></div><div><div class="c-pct" style="font-size:16px">25</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-pt"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">일부</div></div>
    <div class="sr s-no"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">미시작</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:25%"></div></div>
    <div class="c-note">단일 Rule만 구현<br>&#9888; ADR-005 미작성 &#183; REQ-M3-3 미결</div>
  </div>
  <div class="card">
    <div class="ch"><div><div class="c-name">직원 수당</div><div class="c-en">Staff Earning</div></div><div><div class="c-pct" style="font-size:16px">35</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-ok"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">완료</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:35%"></div></div>
    <div class="c-note">StaffEarningEngine &#183; ADR-006<br>화면 골격만 &#183; UI 미연결</div>
  </div>
</div>

<div class="map-sec">운영 지원 도메인</div>
<div class="g4">
  <div class="card">
    <div class="ch"><div><div class="c-name">고객</div><div class="c-en">Customer</div></div><div><div class="c-pct" style="font-size:15px">20</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-pt"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">일부</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:20%"></div></div>
  </div>
  <div class="card">
    <div class="ch"><div><div class="c-name">재고</div><div class="c-en">Inventory</div></div><div><div class="c-pct" style="font-size:15px">5</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-no"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">미시작</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:5%"></div></div>
  </div>
  <div class="card">
    <div class="ch"><div><div class="c-name">현금/시재</div><div class="c-en">Cash Mgmt</div></div><div><div class="c-pct" style="font-size:15px">5</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-no"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">미시작</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:5%"></div></div>
  </div>
  <div class="card">
    <div class="ch"><div><div class="c-name">선불권</div><div class="c-en">Prepaid Pass</div></div><div><div class="c-pct" style="font-size:15px">5</div><div class="c-pct-u">%</div></div></div>
    <div class="sr s-no"><div class="sr-l">ENGINE</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">미시작</div></div>
    <div class="sr s-sk"><div class="sr-l">UI</div><div class="sr-bar"><div class="sr-fill"></div></div><div class="sr-pip">골격</div></div>
    <div class="prog-bar"><div class="prog-fill" style="width:5%"></div></div>
  </div>
</div>

<div class="map-sec">다음 우선순위</div>
<div class="pri-strip">
  <div class="pri-ttl">&#9656; 작업 큐</div>
  <div class="pri-list">
    <div class="pri-item"><div class="pri-n now">01</div><div><div class="pri-nm">A-40 Milestone 3 Closure</div><div class="pri-d">M3 개발 사이클 공식 종료</div></div></div>
    <div class="pri-item"><div class="pri-n">02</div><div><div class="pri-nm">Session/POS UI 연결</div><div class="pri-d">엔진 완성 &#8212; 화면 연결만 남음</div></div></div>
    <div class="pri-item"><div class="pri-n">03</div><div><div class="pri-nm">미매칭 정책 결정</div><div class="pri-d">REQ-M3-2: 로깅 vs 예외</div></div></div>
    <div class="pri-item"><div class="pri-n">04</div><div><div class="pri-nm">ADR-005 작성</div><div class="pri-d">Promotion 복수 Rule 중첩 정책</div></div></div>
  </div>
  <div class="issues">
    <div class="ic w">&#9888; REQ-M3-2 정책 미결</div>
    <div class="ic w">&#9888; REQ-M3-3 ADR-005 미작성</div>
    <div class="ic">CC-1 WaitingEntry.bookingId 미결</div>
    <div class="ic">CC-2 businessType 값 미확인</div>
    <div class="ic">BookingListScreen 테스트 없음</div>
  </div>
</div>

</section><!-- /tab-map -->

<!-- ════════════════ DOCS TAB ════════════════ -->
<section id="tab-docs" class="tab-panel">
  <aside class="doc-sidebar">
    <div class="doc-search-wrap">
      <input class="doc-search" id="docSearch" type="search" placeholder="문서 검색..." oninput="filterDocs(this.value)">
    </div>
    <div class="doc-list" id="docList"></div>
  </aside>
  <div class="doc-pane" id="docPane">
    <div class="doc-placeholder" id="docPH">&#8592; 문서를 선택하세요</div>
    <div class="doc-content" id="docContent" style="display:none">
      <div class="doc-path" id="docPath"></div>
      <div class="md" id="docMd"></div>
    </div>
  </div>
</section>

<!-- ════════════════ LOG TAB ════════════════ -->
<section id="tab-log" class="tab-panel">
  <div class="log-inner">
    <div class="log-hdr">WORK_LOG.md</div>
    <div class="md" id="logMd"></div>
  </div>
</section>

<!-- ════════════════ MEMOS TAB ════════════════ -->
<section id="tab-memos" class="tab-panel">
  <aside class="memo-sidebar">
    <button class="memo-new-btn" onclick="newMemo()">+ 새 메모</button>
    <div class="memo-list" id="memoList"></div>
  </aside>
  <div class="memo-editor-area">
    <div class="memo-placeholder" id="memoPH">&#8592; 메모를 선택하거나 새로 만드세요</div>
    <div class="memo-editor" id="memoEditor" style="display:none">
      <input class="memo-title-input" id="memoTitle" type="text" placeholder="제목" oninput="dirty=true">
      <textarea class="memo-body-input" id="memoBody" placeholder="내용을 입력하세요..." oninput="dirty=true"></textarea>
      <div class="memo-footer">
        <button class="btn primary" onclick="saveMemo()">저장</button>
        <button class="btn danger" onclick="deleteMemo()">삭제</button>
        <span class="memo-date" id="memoDate"></span>
      </div>
    </div>
  </div>
</section>

<script>
/* ── Embedded document data ── */
const DOCS = __DOCS_JSON__;

/* ── Theme ── */
(function(){
  var s = localStorage.getItem('pos2-theme');
  if (s) document.documentElement.setAttribute('data-theme', s);
})();
function toggleTheme() {
  var cur = document.documentElement.getAttribute('data-theme');
  var next = cur === 'light' ? 'dark' : 'light';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('pos2-theme', next);
}

/* ── Tabs ── */
var tabInited = {};
function showTab(name, btn) {
  document.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
  document.getElementById('tab-' + name).classList.add('active');
  btn.classList.add('active');
  if (!tabInited[name]) { tabInited[name] = true; initTab(name); }
}
function initTab(name) {
  if (name === 'docs') initDocs();
  if (name === 'log')  initLog();
  if (name === 'memos') initMemos();
}

/* ── Markdown Parser ── */
function esc(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function inline(text) {
  var codes = [];
  text = text.replace(/`([^`]+)`/g, function(_,c){ codes.push('<code>'+esc(c)+'</code>'); return '\\x00'+(codes.length-1)+'\\x00'; });
  text = esc(text);
  text = text
    .replace(/\\*\\*(.+?)\\*\\*/g,'<strong>$1</strong>')
    .replace(/\\*(.+?)\\*/g,'<em>$1</em>')
    .replace(/\\[([^\\]]+)\\]\\(([^)]+)\\)/g,'<a href="$2" target="_blank" rel="noopener">$1</a>');
  text = text.replace(/\\x00(\\d+)\\x00/g, function(_,i){ return codes[+i]; });
  return text;
}
function md2html(src) {
  var lines = src.split('\\n'), out = [], i = 0;
  while (i < lines.length) {
    var line = lines[i];
    // Fenced code block
    if (line.trimStart().startsWith('```')) {
      var lang = line.trim().slice(3).trim(); i++;
      var buf = [];
      while (i < lines.length && !lines[i].trimStart().startsWith('```')) { buf.push(lines[i]); i++; }
      i++;
      out.push('<pre><code'+(lang?' class="lang-'+esc(lang)+'"':'')+'>'+esc(buf.join('\\n'))+'</code></pre>');
      continue;
    }
    // Table
    if (line.includes('|') && i+1 < lines.length && /^\\|?[\\s\\-|:]+\\|/.test(lines[i+1])) {
      var pc = function(l){ return l.replace(/^\\|/,'').replace(/\\|$/,'').split('|').map(function(c){return c.trim();}); };
      var hdrs = pc(line).map(function(c){return '<th>'+inline(c)+'</th>';}).join('');
      i += 2;
      var rows = [];
      while (i < lines.length && lines[i].includes('|')) {
        rows.push('<tr>'+pc(lines[i]).map(function(c){return '<td>'+inline(c)+'</td>';}).join('')+'</tr>');
        i++;
      }
      out.push('<div class="tw"><table><thead><tr>'+hdrs+'</tr></thead><tbody>'+rows.join('')+'</tbody></table></div>');
      continue;
    }
    // Heading
    var hm = line.match(/^(#{1,6})\\s+(.+)/);
    if (hm) { var lv=hm[1].length; out.push('<h'+lv+'>'+inline(hm[2])+'</h'+lv+'>'); i++; continue; }
    // HR
    if (/^---+\\s*$/.test(line)||/^\\*\\*\\*+\\s*$/.test(line)) { out.push('<hr>'); i++; continue; }
    // Blockquote
    if (line.startsWith('> ')) {
      var bq = [];
      while (i < lines.length && (lines[i].startsWith('> ')||lines[i]==='> '||lines[i]==='>')) { bq.push(lines[i].replace(/^>\\s?/,'')); i++; }
      out.push('<blockquote>'+md2html(bq.join('\\n'))+'</blockquote>');
      continue;
    }
    // UL
    if (/^[\\-\\*\\+] /.test(line)) {
      var ul = [];
      while (i < lines.length && /^[\\-\\*\\+] /.test(lines[i])) { ul.push('<li>'+inline(lines[i].replace(/^[\\-\\*\\+] /,''))+'</li>'); i++; }
      out.push('<ul>'+ul.join('')+'</ul>');
      continue;
    }
    // OL
    if (/^\\d+[\\.\)] /.test(line)) {
      var ol = [];
      while (i < lines.length && /^\\d+[\\.\)] /.test(lines[i])) { ol.push('<li>'+inline(lines[i].replace(/^\\d+[\\.\)] /,''))+'</li>'); i++; }
      out.push('<ol>'+ol.join('')+'</ol>');
      continue;
    }
    // Blank
    if (line.trim() === '') { i++; continue; }
    // Paragraph
    var para = [];
    while (i < lines.length) {
      var l = lines[i];
      if (l.trim()===''||/^#{1,6} /.test(l)||l.trimStart().startsWith('```')||l.startsWith('> ')||/^[\\-\\*\\+] /.test(l)||/^\\d+[\\.\)] /.test(l)||/^---+\\s*$/.test(l)||(l.includes('|')&&i+1<lines.length&&/^\\|?[\\s\\-|:]+\\|/.test(lines[i+1]))) break;
      para.push(l); i++;
    }
    if (para.length) out.push('<p>'+inline(para.join(' '))+'</p>');
  }
  return out.join('\\n');
}

/* ── Document browser ── */
var activeDoc = null;
var DOC_GROUPS = [
  {label:'Milestone 3 (현재)',  test:function(p,n){return /^A3[4-9]_/.test(n)||/^A36_5/.test(n);}},
  {label:'Milestone 2',         test:function(p,n){return /^A(2[6-9]|3[0-3])_/.test(n);}},
  {label:'Milestone 1',         test:function(p,n){return /^A2[0-5]_/.test(n)||/^MILESTONE_1/.test(n)||/^BOOKING_COMPLETION_OPERATOR/.test(n);}},
  {label:'기반 설계 (A8~A19)', test:function(p,n){return /^A(1[0-9]|[89])_/.test(n);}},
  {label:'아키텍처 · ADR',      test:function(p,n){return /^(ARCHITECTURE_|ADR_|ID_CONVENTION|A8_SESSION)/.test(n)||p.startsWith('adr/')||p.startsWith('architecture/');}},
  {label:'운영 · 로드맵',        test:function(p,n){return /^(PROJECT_ROADMAP|WORK_LOG|DECISION_HISTORY|MARK2|MILESTONE_)/.test(n);}},
  {label:'개발 프로세스',        test:function(p,n){return /^(AI_DEVELOPMENT|DEVELOPMENT_|REPAIR_|ENGINEERING_)/.test(n);}},
  {label:'Baseline',            test:function(p,n){return p.startsWith('baseline/');}},
  {label:'기타',                test:function(){return true;}},
];

function docLabel(path) {
  var name = path.split('/').pop().replace(/\\.md$/,'');
  var content = DOCS[path] || '';
  var hm = content.match(/^#\\s+(.+)/m);
  if (hm) return hm[1].replace(/^A-\\d+[\\s:：]+/,'').trim();
  var am = name.match(/^A(\\d+)_(.+)/);
  if (am) return 'A-'+am[1]+': '+am[2].replace(/_/g,' ');
  return name.replace(/_/g,' ');
}
function docShort(path) {
  var name = path.split('/').pop().replace(/\\.md$/,'');
  var am = name.match(/^A(\\d+)/);
  if (am) return 'A-'+am[1];
  return name.replace(/_/g,' ').split(' ').slice(0,3).join(' ');
}

function buildDocList(q) {
  var el = document.getElementById('docList');
  el.innerHTML = '';
  var ql = (q||'').toLowerCase();
  var claimed = {};
  DOC_GROUPS.forEach(function(grp) {
    var items = Object.keys(DOCS).filter(function(p) {
      if (claimed[p]) return false;
      var n = p.split('/').pop().replace(/\\.md$/,'');
      if (ql && p.toLowerCase().indexOf(ql)<0 && docLabel(p).toLowerCase().indexOf(ql)<0) return false;
      return grp.test(p, n);
    });
    if (!items.length) return;
    items.forEach(function(p){ claimed[p]=true; });
    var hdr = document.createElement('div');
    hdr.className = 'doc-grp-hdr';
    hdr.textContent = grp.label;
    el.appendChild(hdr);
    items.forEach(function(path) {
      var btn = document.createElement('button');
      btn.className = 'doc-item'+(path===activeDoc?' active':'');
      btn.dataset.path = path;
      btn.title = path;
      btn.textContent = docShort(path)+' — '+docLabel(path);
      btn.onclick = function(){ openDoc(path); };
      el.appendChild(btn);
    });
  });
}

function openDoc(path) {
  activeDoc = path;
  document.getElementById('docPH').style.display = 'none';
  var wrap = document.getElementById('docContent');
  wrap.style.display = 'block';
  document.getElementById('docPath').textContent = path;
  document.getElementById('docMd').innerHTML = md2html(DOCS[path]||'');
  document.querySelectorAll('.doc-item').forEach(function(b){ b.classList.toggle('active', b.dataset.path===path); });
  document.getElementById('docPane').scrollTop = 0;
}

function filterDocs(v) { buildDocList(v); }

function initDocs() { buildDocList(''); }

/* ── Work Log ── */
function initLog() {
  var wl = DOCS['WORK_LOG.md'] || '';
  document.getElementById('logMd').innerHTML = wl
    ? md2html(wl)
    : '<p style="color:var(--muted)">WORK_LOG.md를 찾을 수 없습니다.</p>';
}

/* ── Memos ── */
var MEMO_KEY = 'salon-pos-v2-memos';
var activeMemo = null;
var dirty = false;

function getMemos() { try { return JSON.parse(localStorage.getItem(MEMO_KEY)||'[]'); } catch(e){ return []; } }
function setMemos(list) { localStorage.setItem(MEMO_KEY, JSON.stringify(list)); }
function fmtDate(iso) {
  var d = new Date(iso);
  return d.getFullYear()+'.'+('0'+(d.getMonth()+1)).slice(-2)+'.'+('0'+d.getDate()).slice(-2);
}

function renderMemoList() {
  var el = document.getElementById('memoList');
  var list = getMemos();
  if (!list.length) { el.innerHTML = '<div style="padding:14px 11px;font-size:12px;color:var(--muted)">메모가 없습니다</div>'; return; }
  el.innerHTML = '';
  list.forEach(function(m) {
    var btn = document.createElement('button');
    btn.className = 'memo-item'+(m.id===activeMemo?' active':'');
    btn.dataset.id = m.id;
    btn.innerHTML = '<div class="memo-item-title">'+esc(m.title||'(제목 없음)')+'</div>'
      +'<div class="memo-item-date">'+fmtDate(m.updatedAt||m.createdAt)+'</div>';
    btn.onclick = function(){ openMemo(m.id); };
    el.appendChild(btn);
  });
}

function openMemo(id) {
  if (dirty && activeMemo && !confirm('저장하지 않은 변경사항이 있습니다. 계속하시겠습니까?')) return;
  activeMemo = id; dirty = false;
  var m = getMemos().find(function(x){ return x.id===id; });
  if (!m) return;
  document.getElementById('memoPH').style.display = 'none';
  document.getElementById('memoEditor').style.display = 'flex';
  document.getElementById('memoTitle').value = m.title||'';
  document.getElementById('memoBody').value = m.body||'';
  document.getElementById('memoDate').textContent = '작성: '+fmtDate(m.createdAt);
  renderMemoList();
}

function newMemo() {
  var m = {id:Date.now(),title:'',body:'',createdAt:new Date().toISOString(),updatedAt:new Date().toISOString()};
  var list = getMemos(); list.unshift(m); setMemos(list);
  openMemo(m.id);
}
function saveMemo() {
  if (!activeMemo) return;
  var list = getMemos(), idx = list.findIndex(function(m){return m.id===activeMemo;});
  if (idx<0) return;
  list[idx].title = document.getElementById('memoTitle').value;
  list[idx].body  = document.getElementById('memoBody').value;
  list[idx].updatedAt = new Date().toISOString();
  setMemos(list); dirty = false; renderMemoList();
}
function deleteMemo() {
  if (!activeMemo) return;
  if (!confirm('이 메모를 삭제할까요?')) return;
  setMemos(getMemos().filter(function(m){return m.id!==activeMemo;}));
  activeMemo = null; dirty = false;
  document.getElementById('memoPH').style.display = '';
  document.getElementById('memoEditor').style.display = 'none';
  renderMemoList();
}
function initMemos() { renderMemoList(); }

// Ctrl+S / Cmd+S to save memo
document.addEventListener('keydown', function(e) {
  if ((e.ctrlKey||e.metaKey) && e.key==='s') { e.preventDefault(); if(activeMemo) saveMemo(); }
});
</script>
</body>
</html>
"""


def main():
    print('Building WORLD_MAP.html...')
    docs = gather_docs()
    commits, dart_files = git_stats()

    json_str = json.dumps(docs, ensure_ascii=False, separators=(',', ':'))
    # Prevent </script> from prematurely closing the script tag
    json_str = json_str.replace('</', '<\\/')

    html = TEMPLATE
    html = html.replace('__DOCS_JSON__', json_str)
    html = html.replace('__COMMITS__', str(commits))
    html = html.replace('__DART_FILES__', str(dart_files))

    OUTPUT.write_text(html, encoding='utf-8')
    size_kb = OUTPUT.stat().st_size // 1024
    print(f'  {len(docs)} docs embedded  |  {commits} commits  |  {dart_files} Dart files')
    print(f'  Output: {OUTPUT.relative_to(ROOT)}  ({size_kb} KB)')
    print('Done.')


if __name__ == '__main__':
    main()
