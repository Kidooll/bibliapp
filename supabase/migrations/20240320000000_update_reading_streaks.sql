-- Atualiza a tabela reading_streaks
ALTER TABLE reading_streaks
DROP COLUMN IF EXISTS is_current;

-- Adiciona índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_reading_streaks_user_profile_id ON reading_streaks(user_profile_id);
CREATE INDEX IF NOT EXISTS idx_reading_streaks_last_active_date ON reading_streaks(last_active_date);

-- Função para obter a sequência atual
CREATE OR REPLACE FUNCTION get_current_streak(p_user_profile_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_streak_days INTEGER;
BEGIN
    SELECT current_streak_days INTO v_streak_days
    FROM reading_streaks
    WHERE user_profile_id = p_user_profile_id
    ORDER BY last_active_date DESC
    LIMIT 1;
    
    RETURN COALESCE(v_streak_days, 0);
END;
$$ LANGUAGE plpgsql;

-- Função para obter a maior sequência
CREATE OR REPLACE FUNCTION get_longest_streak(p_user_profile_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_longest_streak INTEGER;
BEGIN
    SELECT longest_streak_days INTO v_longest_streak
    FROM reading_streaks
    WHERE user_profile_id = p_user_profile_id
    ORDER BY longest_streak_days DESC
    LIMIT 1;
    
    RETURN COALESCE(v_longest_streak, 0);
END;
$$ LANGUAGE plpgsql; 