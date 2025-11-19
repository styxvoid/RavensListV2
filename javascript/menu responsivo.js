// ============================================
// RAVEN'S LIST - JAVASCRIPT
// Menu Hamburguer Responsivo e Interações
// ============================================

// Função para abrir/fechar o menu mobile
function toggleMenu() {
    const navLinks = document.getElementById('navLinks');
    navLinks.classList.toggle('active');
}

// Aguardar o carregamento completo do DOM
document.addEventListener('DOMContentLoaded', function() {
    
    // ============================================
    // FECHAR MENU AO CLICAR EM LINKS OU BOTÕES
    // ============================================
    const menuItems = document.querySelectorAll('.nav-links a, .nav-links button');
    
    menuItems.forEach(item => {
        item.addEventListener('click', () => {
            const navLinks = document.getElementById('navLinks');
            if (navLinks.classList.contains('active')) {
                navLinks.classList.remove('active');
            }
        });
    });

    // ============================================
    // FECHAR MENU AO CLICAR FORA DELE
    // ============================================
    document.addEventListener('click', (e) => {
        const nav = document.querySelector('nav');
        const navLinks = document.getElementById('navLinks');
        const menuToggle = document.querySelector('.menu-toggle');
        
        // Verifica se o clique foi fora do menu e se o menu está aberto
        if (!nav.contains(e.target) && navLinks.classList.contains('active')) {
            navLinks.classList.remove('active');
        }
    });

    // ============================================
    // SCROLL SUAVE PARA ÂNCORAS
    // ============================================
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    
    anchorLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            
            // Ignora links vazios ou apenas "#"
            if (href === '#' || href === '#top') {
                if (href === '#top') {
                    e.preventDefault();
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                }
                return;
            }
            
            const target = document.querySelector(href);
            
            if (target) {
                e.preventDefault();
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // ============================================
    // ANIMAÇÃO DOS CARDS AO SCROLL (OPCIONAL)
    // ============================================
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Aplicar animação aos cards de eventos
    const eventCards = document.querySelectorAll('.event-card');
    eventCards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        card.style.transition = 'all 0.6s ease';
        observer.observe(card);
    });

    // ============================================
    // ADICIONAR CLASSE ACTIVE NA NAVEGAÇÃO
    // Destaca o link da seção atual
    // ============================================
    const sections = document.querySelectorAll('section[id]');
    
    function highlightNavigation() {
        const scrollY = window.pageYOffset;
        
        sections.forEach(section => {
            const sectionHeight = section.offsetHeight;
            const sectionTop = section.offsetTop - 100;
            const sectionId = section.getAttribute('id');
            const navLink = document.querySelector(`.nav-links a[href="#${sectionId}"]`);
            
            if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
                if (navLink) {
                    // Remove active de todos os links
                    document.querySelectorAll('.nav-links a').forEach(link => {
                        link.classList.remove('active-link');
                    });
                    // Adiciona active ao link atual
                    navLink.classList.add('active-link');
                }
            }
        });
    }

    // Executar ao fazer scroll
    window.addEventListener('scroll', highlightNavigation);

// ============================================
// BOTÕES DE COMPRA - PLACEHOLDER (CORRIGIDO)
// ============================================

// Seleciona os botões de compra que estão DENTRO do 2º card de evento (.event-card:nth-child(2)) 
// e dos cards seguintes (n+2), EXCLUINDO o 1º card.
const buyButtons = document.querySelectorAll('.event-card:nth-child(n+2) .btn-buy');

buyButtons.forEach(button => {
    button.addEventListener('click', function() {
        const eventCard = this.closest('.event-card');
        
        // Verifica se eventCard foi encontrado antes de tentar ler o título
        if (eventCard) { 
            const eventTitle = eventCard.querySelector('.event-title').textContent;
            
            alert(`🦇 Redirecionando para compra de:\n"${eventTitle}"\n\nEm breve, sistema de pagamento estará disponível!`);
            
        }
    });
});
    // ============================================
    // BOTÕES LOGIN E CADASTRO - PLACEHOLDER
    // ============================================
    const loginBtn = document.querySelector('.btn-login');
    const cadastroBtn = document.querySelectorAll('.btn:not(.btn-login):not(.btn-buy)');
    
    if (loginBtn) {
        loginBtn.addEventListener('click', function() {
            alert('🦇 "Denn die Todten reiten Schnell."\n\n- Gottfried August Bürger');
            // window.location.href = 'login.html';
        });
    }
    
    cadastroBtn.forEach(btn => {
        if (btn.textContent.trim() === 'Cadastro') {
            btn.addEventListener('click', function() {
                alert('🦇 "Abandonai toda esperança vós que entrai"\n\n- Dante Allighieri.');
                // window.location.href = 'cadastro.html';
            });
        }
    });

    // ============================================
    // ADICIONAR EFEITO DE TYPING NO SUBTÍTULO (OPCIONAL)
    // ============================================
    const subtitle = document.querySelector('.subtitle');
    if (subtitle) {
        const text = subtitle.textContent;
        subtitle.textContent = '';
        let i = 0;
        
        function typeWriter() {
            if (i < text.length) {
                subtitle.textContent += text.charAt(i);
                i++;
                setTimeout(typeWriter, 50);
            }
        }
        
        // Descomentar para ativar efeito de digitação
        // typeWriter();
    }

    console.log('🦇 Raven\'s List - JavaScript carregado com sucesso!');
});

// ============================================
// PREVENIR COMPORTAMENTOS INDESEJADOS
// ============================================

// Prevenir duplo clique nos botões
document.querySelectorAll('button').forEach(button => {
    button.addEventListener('dblclick', (e) => {
        e.preventDefault();
    });
});

// Adicionar indicador de carregamento (opcional)
window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});