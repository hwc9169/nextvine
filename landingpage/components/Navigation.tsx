'use client'

import { Button } from './ui/Button'
import { Container } from './ui/Container'
import { Globe } from 'lucide-react'
import { useLanguage } from '@/lib/language-context'
import { useEffect, useState } from 'react'

// 커스텀 훅으로 스크롤 기능 추가
function useScrollToSection() {
  const scrollToSection = (sectionIndex: number) => {
    // FullPageScroll 컴포넌트의 스크롤 함수 호출
    const event = new CustomEvent('scrollToSection', { 
      detail: { sectionIndex } 
    })
    window.dispatchEvent(event)
  }
  
  return { scrollToSection }
}

export function Navigation() {
  const { language, setLanguage } = useLanguage()
  const { scrollToSection } = useScrollToSection()
  const [currentSection, setCurrentSection] = useState(0)

  const toggleLanguage = () => {
    setLanguage(language === 'ko' ? 'en' : 'ko')
  }

  const handleNotifyClick = () => {
    // Contact 섹션(마지막 섹션)으로 스크롤 - 인덱스 8
    scrollToSection(8)
  }

  // 현재 섹션 감지
  useEffect(() => {
    const detectCurrentSection = () => {
      const sections = document.querySelectorAll('section')
      const scrollTop = window.scrollY || document.documentElement.scrollTop
      const windowHeight = window.innerHeight

      for (let i = 0; i < sections.length; i++) {
        const section = sections[i]
        const rect = section.getBoundingClientRect()
        
        // 섹션이 화면 중앙에 위치하는지 확인
        if (rect.top <= windowHeight / 2 && rect.bottom >= windowHeight / 2) {
          setCurrentSection(i)
          break
        }
      }
    }

    // 초기 감지
    detectCurrentSection()

    // 스크롤 이벤트 리스너
    window.addEventListener('scroll', detectCurrentSection)
    
    // FullPageScroll의 섹션 변경 이벤트 리스너
    const handleSectionChange = (e: CustomEvent) => {
      setCurrentSection(e.detail.sectionIndex)
    }
    
    window.addEventListener('sectionChanged' as any, handleSectionChange)

    return () => {
      window.removeEventListener('scroll', detectCurrentSection)
      window.removeEventListener('sectionChanged' as any, handleSectionChange)
    }
  }, [])

  // Features 섹션(인덱스 2)부터 logo-b.svg 사용, 하지만 Reasons 섹션(인덱스 7)과 Contact 섹션(인덱스 8)에서는 logo.svg 사용
  const logoSrc = (currentSection === 7 || currentSection === 8) ? '/images/logo.svg' : (currentSection >= 2 ? '/images/logo-b.svg' : '/images/logo.svg')

  return (
    <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-md">
      <Container size="1600">
        <nav className="flex items-center justify-between h-16 px-4 sm:px-6 lg:px-8">
          {/* 로고 */}
          <div className="flex-shrink-0 cursor-pointer flex items-center" onClick={() => scrollToSection(0)}>
            <img 
              src={logoSrc} 
              alt="Scoliscan Logo"
              className="h-8 w-auto transition-all duration-300"
            />
          </div>

          {/* 중앙 여백 */}
          <div className="flex-1"></div>

          {/* 언어 전환 및 CTA */}
          <div className="flex items-center space-x-2 sm:space-x-4">
            {/* 언어 전환 버튼 */}
            <button
              onClick={toggleLanguage}
              className={`flex items-center space-x-1 sm:space-x-2 px-2 sm:px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                (currentSection === 7 || currentSection === 8)
                  ? 'text-white hover:bg-gray-100/20'
                  : currentSection >= 2 
                  ? 'text-black hover:bg-gray-100' 
                  : 'text-white hover:bg-gray-100'
              }`}
            >
              <Globe className="w-4 h-4" />
              <span className="uppercase font-semibold text-xs sm:text-sm">
                {language === 'ko' ? 'KR' : 'EN'}
              </span>
            </button>

            {/* 출시 알림 받기 버튼 */}
            <Button 
              variant={(currentSection === 7 || currentSection === 8) ? "white" : (currentSection >= 2 ? "primary" : "white")}
              onClick={handleNotifyClick}
              size="sm"
              className="whitespace-nowrap text-xs sm:text-sm px-2 sm:px-4 py-1 sm:py-2"
            >
              <span className="hidden sm:inline">
                {language === 'ko' ? '출시 알림 받기' : 'Get Launch Notifications'}
              </span>
              <span className="sm:hidden">
                {language === 'ko' ? '알림받기' : 'Notify'}
              </span>
            </Button>
          </div>
        </nav>
      </Container>
    </header>
  )
}