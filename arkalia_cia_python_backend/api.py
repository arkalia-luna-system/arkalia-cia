@app.get("/api/ai/conversations")
@limiter.limit("60/minute")
async def get_ai_conversations(request: Request, limit: int = 50):
    """Récupère l'historique des conversations IA"""
    if limit > 100:
        limit = 100
    conversations = db.get_ai_conversations(limit=limit)
    return conversations


# === IA PATTERNS ===


class PatternAnalysisRequest(BaseModel):
    data: list[dict] = Field(..., description="Données temporelles à analyser")


@app.post("/api/patterns/analyze")
@limiter.limit("20/minute")
async def analyze_patterns(request: Request, pattern_request: PatternAnalysisRequest):
    """Analyse patterns dans les données"""
    try:
        patterns = pattern_analyzer.detect_temporal_patterns(pattern_request.data)
        return patterns
    except Exception as e:
        logger.error(f"Erreur analyse patterns: {sanitize_log_message(str(e))}")
        raise HTTPException(status_code=500, detail="Erreur lors de l'analyse des patterns")
