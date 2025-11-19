// ============================================
// CRUD DE EVENTOS - CORRIGIDO E FUNCIONAL
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
// CARREGAR DADOS DO EVENTO
// ============================================
async function carregarDadosEvento(eventoId) {
    try {
        const response = await fetch(`php/crudEventos.php?acao=buscar&id=${eventoId}`);
        const data = await response.json();
        
        if (data.success) {
            const evento = data.evento;
            
            document.getElementById('modalTitulo').textContent = evento.titulo;
            
            document.getElementById('infoEvento').innerHTML = `
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">📅 Data:</span>
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
                        <span class="info-label">👥 Capacidade:</span>
                        <span class="info-value">${evento.capacidade_total} pessoas</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">🎫 Vendidos:</span>
                        <span class="info-value">${evento.ingressos_vendidos}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">✅ Disponíveis:</span>
                        <span class="info-value">${evento.ingressos_disponiveis}</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">📊 Ocupação:</span>
                        <span class="info-value">${calcularOcupacao(evento.ingressos_vendidos, evento.capacidade_total)}%</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">💰 Status:</span>
                        <span class="info-value status-${evento.status_evento}">${formatarStatus(evento.status_evento)}</span>
                    </div>
                </div>
            `;
        } else {
            mostrarMensagem(data.message, 'erro');
        }
    } catch (error) {
        console.error('Erro ao carregar evento:', error);
        mostrarMensagem('Erro ao carregar dados do evento', 'erro');
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
                const loteCard = document.createElement('div');
                loteCard.className = 'lote-card';
                loteCard.innerHTML = `
                    <div class="lote-header">
                        <h4>${lote.nome_lote}</h4>
                        <span class="lote-status status-${lote.status_lote}">${formatarStatus(lote.status_lote)}</span>
                    </div>
                    <div class="lote-info">
                        <p><strong>Inteira:</strong> R$ ${parseFloat(lote.preco_inteira).toFixed(2)}</p>
                        <p><strong>Meia:</strong> R$ ${parseFloat(lote.preco_meia).toFixed(2)}</p>
                        <p><strong>Total:</strong> ${lote.quantidade_total} ingressos</p>
                        <p><strong>Vendidos:</strong> ${lote.quantidade_vendida}</p>
                        <p><strong>Disponíveis:</strong> ${lote.quantidade_disponivel}</p>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: ${(lote.quantidade_vendida / lote.quantidade_total * 100)}%"></div>
                        </div>
                        <p class="progress-text">${((lote.quantidade_vendida / lote.quantidade_total * 100).toFixed(1))}% vendido</p>
                    </div>
                    <div class="lote-actions">
                        <button onclick="excluirLote(${lote.id})" class="btn-delete">🗑️ Excluir</button>
                    </div>
                `;
                lotesContainer.appendChild(loteCard);
            });
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
                        <p><strong>Cliente:</strong> ${ingresso.usuario_nome}</p>
                        <p><strong>Email:</strong> ${ingresso.usuario_email}</p>
                        <p><strong>Lote:</strong> ${ingresso.nome_lote || 'N/A'}</p>
                        <p><strong>Tipo:</strong> ${ingresso.tipo_ingresso === 'inteira' ? 'Inteira' : 'Meia'}</p>
                        <p><strong>Quantidade:</strong> ${ingresso.quantidade}</p>
                        <p><strong>Valor:</strong> R$ ${parseFloat(ingresso.valor_final).toFixed(2)}</p>
                        <p><strong>Pagamento:</strong> ${formatarFormaPagamento(ingresso.forma_pagamento)}</p>
                        <p><strong>Data:</strong> ${formatarDataHora(ingresso.data_compra)}</p>
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
    
    console.log('🦇 Sistema CRUD de eventos carregado!');
});