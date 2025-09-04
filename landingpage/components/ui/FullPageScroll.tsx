'use client'

import { useEffect, useRef, useState } from 'react'
import { motion } from 'framer-motion'

interface FullPageScrollProps {
  children: React.ReactNode | React.ReactNode[]
  className?: string
}

export function FullPageScroll({ children, className = '' }: FullPageScrollProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const [currentSection, setCurrentSection] = useState(0)
  const [isScrolling, setIsScrolling] = useState(false)
  const [isMobile, setIsMobile] = useState(false)
  const touchStartY = useRef<number>(0)

  // children을 배열로 변환
  const childrenArray = Array.isArray(children) ? children : [children]

  const scrollToSection = (sectionIndex: number) => {
    if (isScrolling || sectionIndex < 0 || sectionIndex >= childrenArray.length) return
    
    setIsScrolling(true)
    setCurrentSection(sectionIndex)
    
    // 섹션 변경 이벤트 발생
    const event = new CustomEvent('sectionChanged', { 
      detail: { sectionIndex } 
    })
    window.dispatchEvent(event)
    
    if (containerRef.current) {
      const targetY = sectionIndex * window.innerHeight
      containerRef.current.style.transform = `translateY(-${targetY}px)`
    }
    
    setTimeout(() => {
      setIsScrolling(false)
    }, 800)
  }

  useEffect(() => {
    // 화면 크기 감지
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 1024) // lg 브레이크포인트
    }

    checkMobile()
    window.addEventListener('resize', checkMobile)

    // 외부에서 스크롤 섹션 이벤트 처리
    const handleScrollToSection = (e: CustomEvent) => {
      if (!isMobile) {
        scrollToSection(e.detail.sectionIndex)
      }
    }

    window.addEventListener('scrollToSection', handleScrollToSection as EventListener)

    const handleWheel = (e: WheelEvent) => {
      if (isMobile || isScrolling) return
      
      // Services 섹션(인덱스 6)에서는 휠 이벤트를 처리하지 않음
      if (currentSection === 6) {
        return // Services 섹션에서 자체 처리하도록 함
      }
      
      e.preventDefault()
      
      if (e.deltaY > 0) {
        // 아래로 스크롤
        scrollToSection(currentSection + 1)
      } else {
        // 위로 스크롤
        scrollToSection(currentSection - 1)
      }
    }

    const handleKeyDown = (e: KeyboardEvent) => {
      if (isMobile || isScrolling) return
      
      switch (e.key) {
        case 'ArrowDown':
        case 'PageDown':
          e.preventDefault()
          scrollToSection(currentSection + 1)
          break
        case 'ArrowUp':
        case 'PageUp':
          e.preventDefault()
          scrollToSection(currentSection - 1)
          break
        case 'Home':
          e.preventDefault()
          scrollToSection(0)
          break
        case 'End':
          e.preventDefault()
          scrollToSection(childrenArray.length - 1)
          break
      }
    }

    const handleTouchStart = (e: TouchEvent) => {
      if (isMobile) return // 모바일에서는 기본 터치 동작
      touchStartY.current = e.touches[0].clientY
    }

    const handleTouchEnd = (e: TouchEvent) => {
      if (isMobile || isScrolling) return
      
      const touchEndY = e.changedTouches[0].clientY
      const diff = touchStartY.current - touchEndY
      const minSwipeDistance = 50
      
      if (Math.abs(diff) > minSwipeDistance) {
        if (diff > 0) {
          // 위로 스와이프 (아래 섹션으로)
          scrollToSection(currentSection + 1)
        } else {
          // 아래로 스와이프 (위 섹션으로)
          scrollToSection(currentSection - 1)
        }
      }
    }

    // 이벤트 리스너 등록 (모바일이 아닐 때만)
    if (!isMobile) {
      window.addEventListener('wheel', handleWheel, { passive: false })
      window.addEventListener('keydown', handleKeyDown)
      window.addEventListener('touchstart', handleTouchStart, { passive: true })
      window.addEventListener('touchend', handleTouchEnd, { passive: true })
    }

    return () => {
      window.removeEventListener('resize', checkMobile)
      window.removeEventListener('scrollToSection', handleScrollToSection as EventListener)
      if (!isMobile) {
        window.removeEventListener('wheel', handleWheel)
        window.removeEventListener('keydown', handleKeyDown)
        window.removeEventListener('touchstart', handleTouchStart)
        window.removeEventListener('touchend', handleTouchEnd)
      }
    }
  }, [currentSection, isScrolling, childrenArray.length, isMobile])

  // 창 크기 변경 시 현재 섹션으로 다시 스크롤
  useEffect(() => {
    const handleResize = () => {
      if (containerRef.current) {
        const targetY = currentSection * window.innerHeight
        containerRef.current.style.transform = `translateY(-${targetY}px)`
      }
    }

    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [currentSection])

  if (isMobile) {
    // 모바일에서는 일반 스크롤 레이아웃
    return (
      <div className={`${className}`}>
        {childrenArray.map((child, index) => (
          <section
            key={index}
            className="min-h-screen w-full relative"
          >
            {child}
          </section>
        ))}
      </div>
    )
  }

  return (
    <div className={`fixed inset-0 overflow-hidden ${className}`}>
      {/* 스크롤 인디케이터 */}
      <div className="fixed right-6 top-1/2 transform -translate-y-1/2 z-50 space-y-3">
        {childrenArray.map((_, index) => {
          // 흰색 배경 섹션들 (About, Features, Interactive, Solution, Monitoring, Services)
          const isLightSection = currentSection >= 1 && currentSection <= 6
          
          return (
            <button
              key={index}
              onClick={() => scrollToSection(index)}
              className={`block w-3 h-3 rounded-full border-2 transition-all duration-300 ${
                currentSection === index
                  ? 'bg-primary-600 border-primary-600 scale-125'
                  : isLightSection 
                    ? 'bg-transparent border-gray-300 hover:border-gray-400' 
                    : 'bg-transparent border-white/60 hover:border-white'
              }`}
              aria-label={`Go to section ${index + 1}`}
            />
          )
        })}
      </div>

      {/* 섹션 컨테이너 */}
      <motion.div
        ref={containerRef}
        className="flex flex-col"
        style={{
          height: `${childrenArray.length * 100}vh`,
          transition: 'transform 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        }}
      >
        {childrenArray.map((child, index) => (
          <section
            key={index}
            className="h-screen w-full flex-shrink-0 relative"
            style={{ height: '100vh' }}
          >
            {child}
          </section>
        ))}
      </motion.div>
    </div>
  )
}