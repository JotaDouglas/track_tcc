-- Script para sincronizar message_id da tabela usuarios para grupo_membros
-- Execute este script no SQL Editor do Supabase

-- IMPORTANTE: Este script NÃO adiciona coluna na tabela grupo_membros
-- A coluna message_id já existe na tabela usuarios e será buscada via JOIN
-- O repositório foi atualizado para buscar message_id através do relacionamento

-- Verificar se todos os usuários têm message_id preenchido
SELECT
  u.id_usuario,
  u.nome,
  u.sobrenome,
  u.email,
  u.message_id,
  CASE
    WHEN u.message_id IS NULL THEN 'SEM MESSAGE_ID'
    ELSE 'OK'
  END as status
FROM usuarios u
ORDER BY u.message_id NULLS FIRST;

-- Caso algum usuário não tenha message_id, ele precisará fazer login novamente
-- para que o OneSignal gere um novo player_id e seja salvo
