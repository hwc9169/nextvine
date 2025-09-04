'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronUp } from 'lucide-react'

export function ScrollToTop() {
  const [isVisible, setIsVisible] = useState(true)

  // 스크롤 위치에 따라 버튼 표시/숨김
  useEffect(() => {
    const toggleVisibility = () => {
      // 스크롤이 100px 이상일 때 버튼 표시 (테스트를 위해 낮춤)
      if (window.scrollY > 100) {
        setIsVisible(true)
      } else {
        setIsVisible(false)
      }
    }

    // 초기 실행
    toggleVisibility()
    
    window.addEventListener('scroll', toggleVisibility)
    
    // FullPageScroll의 섹션 변경 이벤트도 감지
    const handleSectionChange = (e: CustomEvent) => {
      if (e.detail.sectionIndex > 0) {
        setIsVisible(true)
      } else {
        setIsVisible(true) // Hero 섹션에서도 버튼을 표시하도록 수정
      }
    }
    
    window.addEventListener('sectionChanged' as any, handleSectionChange)
    
    return () => {
      window.removeEventListener('scroll', toggleVisibility)
      window.removeEventListener('sectionChanged' as any, handleSectionChange)
    }
  }, [])

  const scrollToTop = () => {
    // Hero 섹션(인덱스 0)으로 스크롤
    const event = new CustomEvent('scrollToSection', { 
      detail: { sectionIndex: 0 } 
    })
    window.dispatchEvent(event)
  }

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.button
          initial={{ opacity: 0, scale: 0 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0 }}
          transition={{ duration: 0.3 }}
          onClick={scrollToTop}
          className="fixed bottom-8 right-8 z-50 w-12 h-12 bg-primary-500 hover:bg-primary-600 text-white rounded-full shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center"
          style={{
            backgroundColor: '#22B3A4'
          }}
        >
          <ChevronUp className="w-6 h-6" />
        </motion.button>
      )}
    </AnimatePresence>
  )
}