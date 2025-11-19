// ============================================
// CRUD DE EVENTOS - COM DASHBOARD DE VENDAS
// ============================================

let eventoAtual = null;

// ============================================
// ABRIR MODAL DE CRUD
// ============================================
function abrirCRUD(eventoId) {
    eventoAtual = eventoId;
    const modal = document.getElementById('crudModal');
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    
    carregarDadosEvento(eventoId);
    carregarLotes(eventoId);
    carregarIngressosVendidos(eventoId);
}

// ============================================
// FECHAR MODAL DE CRUD
// ============================================
function fecharCRUD() {
    const modal = document.getElementById('crudModal');
    modal.style.display = 'none';
    document.body.style.overflow = 'auto';
    eventoAtual = null;
}

// ============================================
// CARREGAR DADOS DO EVENTO COM DASHBOARD
// ============================================
async function carregarDadosEvento(eventoId) {
    try {
        const response = await fetch(`php/crudEventos.php?acao=buscar&id=${eventoId}`);
        const data = await response.json();
        
        if (data.success) {
            const evento = data.evento;
            
            document.getElementById('modalTitulo').textContent = evento.titulo;
            
            // Calcular estatísticas
            const ocupacao = calcularOcupacao(evento.ingressos_vendidos, evento.capacidade_total);
            const receitaEstimada = evento.ingressos_vendidos * parseFloat(evento.preco_inteira);
            
            document.getElementById('infoEvento').innerHTML = `
                <!-- Dashboard Principal -->
                <div class="dashboard-header">
                    <h3 style="color: #8b0000; margin-bottom: 1rem;">📊 Dashboard de Vendas</h3>
                </div>
                
                <!-- Cards de Estatísticas -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon">🎫</div>
                        <div class="stat-content">
                            <span class="stat-label">Ingressos Vendidos</span>
                            <span class="stat-value">${evento.ingressos_vendidos}</span>
                            <span class="stat-meta">de ${evento.capacidade_total} total</span>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon">💰</div>
                        <div class="stat-content">
                            <span class="stat-label">Receita Estimada</span>
                            <span class="stat-value">R$ ${receitaEstimada.toLocaleString('pt-BR', {minimumFractionDigits: 2})}</span>
                            <span class="stat-meta">Baseado em vendas</span>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon">📈</div>
                        <div class="stat-content">
                            <span class="stat-label">Taxa de Ocupação</span>
                            <span class="stat-value">${ocupacao}%</span>
                            <span class="stat-meta ${ocupacao >= 80 ? 'text-success' : ocupacao >= 50 ? 'text-warning' : 'text-danger'}">
                                ${ocupacao >= 80 ? 'Excelente!' : ocupacao >= 50 ? 'Bom ritmo' : 'Precisa melhorar'}
                            </span>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon">✅</div>
                        <div class="stat-content">
                            <span class="stat-label">Disponíveis</span>
                            <span class="stat-value">${evento.ingressos_disponiveis}</span>
                            <span class="stat-meta">Restantes para venda</span>
                        </div>
                    </div>
                </div>
                
                <!-- Barra de Progresso de Vendas -->
                <div class="progress-section">
                    <h4 style="color: #8b0000; margin-bottom: 0.5rem;">Progresso de Vendas</h4>
                    <div class="progress-bar-large">
                        <div class="progress-fill-large" style="width: ${ocupacao}%">
                            <span class="progress-label">${ocupacao}%</span>
                        </div>
                    </div>
                    <div class="progress-info">
                        <span>0</span>
                        <span style="color: #8b0000; font-weight: bold;">${evento.ingressos_vendidos} vendidos</span>
                        <span>${evento.capacidade_total}</span>
                    </div>
                </div>
                
                <!-- Informações Detalhadas -->
                <div class="info-section">
                    <h4 style="color: #8b0000; margin-bottom: 1rem;">📋 Informações do Evento</h4>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">📅 Data e Hora:</span>
                            <span class="info-value">${formatarData(evento.data_evento)}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">📍 Local:</span>
                            <span class="info-value">${evento.local}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">🏙️ Cidade:</span>
                            <span class="info-value">${evento.cidade || 'N/A'} - ${evento.estado || 'N/A'}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">🎭 Categoria:</span>
                            <span class="info-value">${evento.categoria || 'N/A'}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">💵 Preço Inteira:</span>
                            <span class="info-value">R$ ${parseFloat(evento.preco_inteira).toFixed(2)}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">💵 Preço Meia:</span>
                            <span class="info-value">R$ ${parseFloat(evento.preco_meia).toFixed(2)}</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">🔞 Classificação:</span>
                            <span class="info-value">${evento.classificacao_etaria}+ anos</span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">⭐ Status:</span>
                            <span class="info-value status-${evento.status_evento}">${formatarStatus(evento.status_evento)}</span>
                        </div>
                    </div>
                </div>
                
                <!-- Estatísticas Adicionais -->
                <div class="additional-stats">
                    <div class="stat-box">
                        <span class="stat-box-label">Ticket Médio Estimado</span>
                        <span class="stat-box-value">R$ ${((parseFloat(evento.preco_inteira) + parseFloat(evento.preco_meia)) / 2).toFixed(2)}</span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-box-label">Potencial Máximo</span>
                        <span class="stat-box-value">R$ ${(evento.capacidade_total * parseFloat(evento.preco_inteira)).toLocaleString('pt-BR', {minimumFractionDigits: 2})}</span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-box-label">Meta de Vendas</span>
                        <span class="stat-box-value">${Math.ceil(evento.capacidade_total * 0.8)} ingressos (80%)</span>
                    </div>
                </div>
            `;
            
            // Buscar estatísticas de vendas detalhadas
            carregarEstatisticasVendas(eventoId);
        } else {
            mostrarMensagem(data.message, 'erro');
        }
    } catch (error) {
        console.error('Erro ao carregar evento:', error);
        mostrarMensagem('Erro ao carregar dados do evento', 'erro');
    }
}

// ============================================
// CARREGAR ESTATÍSTICAS DE VENDAS DETALHADAS
// ============================================
async function carregarEstatisticasVendas(eventoId) {
    try {
        const response = await fetch(`php/crudEventos.php?acao=estatisticas_vendas&evento_id=${eventoId}`);
        const data = await response.json();
        
        if (data.success) {
            const stats = data.estatisticas;
            
            // Adicionar gráfico de vendas por tipo
            const vendaContainer = document.createElement('div');
            vendaContainer.className = 'vendas-tipo-section';
            vendaContainer.innerHTML = `
                <h4 style="color: #8b0000; margin-bottom: 1rem;">📊 Vendas por Tipo de Ingresso</h4>
                <div class="vendas-tipo-grid">
                    <div class="tipo-card">
                        <div class="tipo-icon">🎫</div>
                        <div class="tipo-info">
                            <span class="tipo-label">Inteira</span>
                            <span class="tipo-value">${stats.total_inteira || 0}</span>
                            <div class="tipo-bar">
                                <div class="tipo-bar-fill" style="width: ${stats.percent_inteira || 0}%"></div>
                            </div>
                            <span class="tipo-percent">${stats.percent_inteira || 0}%</span>
                        </div>
                    </div>
                    <div class="tipo-card">
                        <div class="tipo-icon">🎟️</div>
                        <div class="tipo-info">
                            <span class="tipo-label">Meia</span>
                            <span class="tipo-value">${stats.total_meia || 0}</span>
                            <div class="tipo-bar">
                                <div class="tipo-bar-fill" style="width: ${stats.percent_meia || 0}%; background: #ff6600;"></div>
                            </div>
                            <span class="tipo-percent">${stats.percent_meia || 0}%</span>
                        </div>
                    </div>
                </div>
                
                <h4 style="color: #8b0000; margin: 2rem 0 1rem 0;">💳 Vendas por Forma de Pagamento</h4>
                <div class="pagamento-grid">
                    <div class="pagamento-item">
                        <span class="pagamento-icon">💰</span>
                        <div class="pagamento-info">
                            <span class="pagamento-label">PIX</span>
                            <span class="pagamento-value">${stats.vendas_pix || 0}</span>
                        </div>
                    </div>
                    <div class="pagamento-item">
                        <span class="pagamento-icon">💳</span>
                        <div class="pagamento-info">
                            <span class="pagamento-label">Cartão Crédito</span>
                            <span class="pagamento-value">${stats.vendas_credito || 0}</span>
                        </div>
                    </div>
                    <div class="pagamento-item">
                        <span class="pagamento-icon">💳</span>
                        <div class="pagamento-info">
                            <span class="pagamento-label">Cartão Débito</span>
                            <span class="pagamento-value">${stats.vendas_debito || 0}</span>
                        </div>
                    </div>
                    <div class="pagamento-item">
                        <span class="pagamento-icon">📄</span>
                        <div class="pagamento-info">
                            <span class="pagamento-label">Boleto</span>
                            <span class="pagamento-value">${stats.vendas_boleto || 0}</span>
                        </div>
                    </div>
                </div>
            `;
            
            document.getElementById('infoEvento').appendChild(vendaContainer);
        }
    } catch (error) {
        console.error('Erro ao carregar estatísticas:', error);
    }
}

// ============================================
// CARREGAR LOTES DO EVENTO
// ============================================
async function carregarLotes(eventoId) {
    try {
        const response = await fetch(`php/crudEventos.php?acao=listar_lotes&evento_id=${eventoId}`);
        const data = await response.json();
        
        if (data.success) {
            const lotesContainer = document.getElementById('listaMateriais');
            lotesContainer.innerHTML = '';
            
            if (data.lotes.length === 0) {
                lotesContainer.innerHTML = '<p class="empty-message">Nenhum lote cadastrado ainda</p>';
                return;
            }
            
            data.lotes.forEach(lote => {
                const percentVendido = (lote.quantidade_vendida / lote.quantidade_total * 100).toFixed(1);
                const loteCard = document.createElement('div');
                loteCard.className = 'lote-card';
                loteCard.innerHTML = `
                    <div class="lote-header">
                        <h4>${lote.nome_lote}</h4>
                        <span class="lote-status status-${lote.status_lote}">${formatarStatus(lote.status_lote)}</span>
                    </div>
                    <div class="lote-info">
                        <p><strong>💵 Inteira:</strong> R$ ${parseFloat(lote.preco_inteira).toFixed(2)}</p>
                        <p><strong>💵 Meia:</strong> R$ ${parseFloat(lote.preco_meia).toFixed(2)}</p>
                        <p><strong>📦 Total:</strong> ${lote.quantidade_total} ingressos</p>
                        <p><strong>✅ Vendidos:</strong> ${lote.quantidade_vendida}</p>
                        <p><strong>📋 Disponíveis:</strong> ${lote.quantidade_disponivel}</p>
                        <p><strong>📅 Período:</strong> ${formatarDataCurta(lote.data_inicio)} até ${formatarDataCurta(lote.data_fim)}</p>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: ${percentVendido}%"></div>
                        </div>
                        <p class="progress-text">${percentVendido}% vendido</p>
                    </div>
                    <div class="lote-actions">
                        <button onclick="excluirLote(${lote.id})" class="btn-delete">🗑️ Excluir</button>
                    </div>
                `;
                lotesContainer.appendChild(loteCard);
            });
            
            // Atualizar dashboard após carregar lotes
            carregarDadosEvento(eventoAtual);
        }
    } catch (error) {
        console.error('Erro ao carregar lotes:', error);
    }
}

// ============================================
// CARREGAR INGRESSOS VENDIDOS
// ============================================
async function carregarIngressosVendidos(eventoId) {
    try {
        const response = await fetch(`php/crudEventos.php?acao=listar_ingressos&evento_id=${eventoId}`);
        const data = await response.json();
        
        if (data.success) {
            const ingressosContainer = document.getElementById('listaIngressos');
            ingressosContainer.innerHTML = '';
            
            if (data.ingressos.length === 0) {
                ingressosContainer.innerHTML = '<p class="empty-message">Nenhum ingresso vendido ainda</p>';
                return;
            }
            
            data.ingressos.forEach(ingresso => {
                const ingressoCard = document.createElement('div');
                ingressoCard.className = 'ingresso-card';
                ingressoCard.innerHTML = `
                    <div class="ingresso-header">
                        <span class="codigo-ingresso">${ingresso.codigo_ingresso}</span>
                        <span class="status-ingresso status-${ingresso.status_ingresso}">${formatarStatus(ingresso.status_ingresso)}</span>
                    </div>
                    <div class="ingresso-info">
                        <p><strong>👤 Cliente:</strong> ${ingresso.usuario_nome}</p>
                        <p><strong>📧 Email:</strong> ${ingresso.usuario_email}</p>
                        <p><strong>🎫 Lote:</strong> ${ingresso.nome_lote || 'N/A'}</p>
                        <p><strong>🎟️ Tipo:</strong> ${ingresso.tipo_ingresso === 'inteira' ? 'Inteira' : 'Meia'}</p>
                        <p><strong>📊 Quantidade:</strong> ${ingresso.quantidade}</p>
                        <p><strong>💰 Valor:</strong> R$ ${parseFloat(ingresso.valor_final).toFixed(2)}</p>
                        <p><strong>💳 Pagamento:</strong> ${formatarFormaPagamento(ingresso.forma_pagamento)}</p>
                        <p><strong>📅 Data:</strong> ${formatarDataHora(ingresso.data_compra)}</p>
                    </div>
                    <div class="ingresso-actions">
                        ${ingresso.status_ingresso === 'confirmado' ? `
                            <button onclick="cancelarIngresso(${ingresso.id})" class="btn-cancel">❌ Cancelar</button>
                            <button onclick="marcarComoUsado(${ingresso.id})" class="btn-use">✅ Marcar Usado</button>
                        ` : ''}
                    </div>
                `;
                ingressosContainer.appendChild(ingressoCard);
            });
            
            // Atualizar dashboard após carregar ingressos
            carregarDadosEvento(eventoAtual);
        }
    } catch (error) {
        console.error('Erro ao carregar ingressos:', error);
    }
}

// ============================================
// ADICIONAR NOVO LOTE
// ============================================
function mostrarFormLote() {
    document.getElementById('formLoteContainer').style.display = 'flex';
}

function fecharFormLote() {
    document.getElementById('formLoteContainer').style.display = 'none';
    document.getElementById('formLote').reset();
}

async function salvarLote(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    formData.append('acao', 'adicionar_lote');
    formData.append('evento_id', eventoAtual);
    
    try {
        const response = await fetch('php/crudEventos.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            mostrarMensagem('Lote adicionado com sucesso!', 'sucesso');
            fecharFormLote();
            carregarLotes(eventoAtual);
            carregarDadosEvento(eventoAtual);
        } else {
            mostrarMensagem(data.message, 'erro');
        }
    } catch (error) {
        console.error('Erro ao salvar lote:', error);
        mostrarMensagem('Erro ao salvar lote', 'erro');
    }
}

// ============================================
// EXCLUIR LOTE
// ============================================
async function excluirLote(loteId) {
    if (!confirm('Tem certeza que deseja excluir este lote?')) {
        return;
    }
    
    try {
        const formData = new FormData();
        formData.append('acao', 'excluir_lote');
        formData.append('lote_id', loteId);
        
        const response = await fetch('php/crudEventos.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            mostrarMensagem('Lote excluído com sucesso!', 'sucesso');
            carregarLotes(eventoAtual);
            carregarDadosEvento(eventoAtual);
        } else {
            mostrarMensagem(data.message, 'erro');
        }
    } catch (error) {
        console.error('Erro ao excluir lote:', error);
        mostrarMensagem('Erro ao excluir lote', 'erro');
    }
}

// ============================================
// CANCELAR INGRESSO
// ============================================
async function cancelarIngresso(ingressoId) {
    if (!confirm('Tem certeza que deseja cancelar este ingresso?')) {
        return;
    }
    
    try {
        const formData = new FormData();
        formData.append('acao', 'cancelar_ingresso');
        formData.append('ingresso_id', ingressoId);
        
        const response = await fetch('php/crudEventos.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            mostrarMensagem('Ingresso cancelado com sucesso!', 'sucesso');
            carregarIngressosVendidos(eventoAtual);
            carregarDadosEvento(eventoAtual);
            carregarLotes(eventoAtual);
        } else {
            mostrarMensagem(data.message, 'erro');
        }
    } catch (error) {
        console.error('Erro ao cancelar ingresso:', error);
        mostrarMensagem('Erro ao cancelar ingresso', 'erro');
    }
}

// ============================================
// MARCAR INGRESSO COMO USADO
// ============================================
async function marcarComoUsado(ingressoId) {
    try {
        const formData = new FormData();
        formData.append('acao', 'marcar_usado');
        formData.append('ingresso_id', ingressoId);
        
        const response = await fetch('php/crudEventos.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            mostrarMensagem('Ingresso marcado como usado!', 'sucesso');
            carregarIngressosVendidos(eventoAtual);
        } else {
            mostrarMensagem(data.message, 'erro');
        }
    } catch (error) {
        console.error('Erro ao marcar ingresso:', error);
        mostrarMensagem('Erro ao marcar ingresso', 'erro');
    }
}

// ============================================
// FUNÇÕES AUXILIARES
// ============================================
function formatarData(dataStr) {
    const data = new Date(dataStr);
    return data.toLocaleDateString('pt-BR', { 
        day: '2-digit', 
        month: 'long', 
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatarDataCurta(dataStr) {
    const data = new Date(dataStr);
    return data.toLocaleDateString('pt-BR', { 
        day: '2-digit', 
        month: '2-digit',
        year: 'numeric'
    });
}

function formatarDataHora(dataStr) {
    const data = new Date(dataStr);
    return data.toLocaleString('pt-BR');
}

function formatarStatus(status) {
    const statusMap = {
        'ativo': 'Ativo',
        'esgotado': 'Esgotado',
        'cancelado': 'Cancelado',
        'finalizado': 'Finalizado',
        'confirmado': 'Confirmado',
        'pendente': 'Pendente',
        'usado': 'Usado',
        'encerrado': 'Encerrado'
    };
    return statusMap[status] || status;
}

function formatarFormaPagamento(forma) {
    const formaMap = {
        'pix': 'PIX',
        'cartao_credito': 'Cartão de Crédito',
        'cartao_debito': 'Cartão de Débito',
        'boleto': 'Boleto'
    };
    return formaMap[forma] || forma;
}

function calcularOcupacao(vendidos, total) {
    if (total === 0) return 0;
    return ((vendidos / total) * 100).toFixed(1);
}

function mostrarMensagem(mensagem, tipo) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message-toast message-${tipo}`;
    messageDiv.textContent = mensagem;
    
    document.body.appendChild(messageDiv);
    
    setTimeout(() => {
        messageDiv.classList.add('show');
    }, 100);
    
    setTimeout(() => {
        messageDiv.classList.remove('show');
        setTimeout(() => {
            document.body.removeChild(messageDiv);
        }, 300);
    }, 3000);
}

// ============================================
// ALTERNAR ENTRE ABAS
// ============================================
function alternarAba(aba) {
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
    });
    
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    
    event.target.classList.add('active');
    document.getElementById(aba).classList.add('active');
}

// ============================================
// INICIALIZAR EVENTOS DOS BOTÕES
// ============================================
document.addEventListener('DOMContentLoaded', () => {
    // Adicionar evento de click nos botões CRUD
    document.querySelectorAll('.btn-crud').forEach((btn, index) => {
        btn.addEventListener('click', () => {
            abrirCRUD(index + 1);
        });
    });
    
    // Fechar modal ao clicar no X
    const closeBtn = document.querySelector('.close-modal');
    if (closeBtn) {
        closeBtn.addEventListener('click', fecharCRUD);
    }
    
    console.log('🦇 Sistema CRUD de eventos com Dashboard carregado!');
});