'use client'

import { motion, AnimatePresence } from 'framer-motion'
import Image from 'next/image'
import { Button } from './Button'
import { X } from 'lucide-react'
import { createPortal } from 'react-dom'
import { useEffect, useState } from 'react'

interface SurveyModalProps {
  isOpen: boolean
  onClose: () => void
  language: 'ko' | 'en'
}

export function SurveyModal({ isOpen, onClose, language }: SurveyModalProps) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const content = {
    ko: {
      title: '참여해 주셔서 감사합니다.',
      subtitle: '더 좋은 서비스를 제공하기 위해 간단한 설문조사를 부탁드립니다.',
      button: '설문조사하러 가기',
      skip: '건너뛰기'
    },
    en: {
      title: 'Thank you for your participation.',
      subtitle: 'We would appreciate a simple survey to provide better services.',
      button: 'Go to Survey',
      skip: 'Skip'
    }
  }

  const handleSurveyClick = () => {
    // 구글 폼 URL로 새 창 열기
    window.open('https://docs.google.com/forms/d/e/1FAIpQLSeMIgEobrea7n5JPkTI9xCergIvcTLp-7wu_q8Zb6QIyNJlrw/viewform?usp=sharing&ouid=118029072171725156830', '_blank')
    onClose()
  }

  if (!mounted) return null

  const modalContent = (
    <AnimatePresence>
      {isOpen && (
        <div 
          className="fixed inset-0 z-[9999] flex items-center justify-center"
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0
          }}
        >
        {/* 배경 오버레이 */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="absolute inset-0 bg-black/50 backdrop-blur-sm"
          onClick={onClose}
        />

        {/* 모달 콘텐츠 */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          transition={{ duration: 0.3, ease: "easeOut" }}
          className="relative bg-white rounded-2xl shadow-2xl p-8 mx-4 max-w-lg w-full"
        >
          {/* 닫기 버튼 */}
          <button
            onClick={onClose}
            className="absolute top-4 right-4 p-2 text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>

          {/* 아이콘 */}
          <div className="text-center mb-6">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.2, duration: 0.5, type: "spring", stiffness: 200 }}
              className="inline-block"
            >
              <Image 
                src="/images/icon-check-waves.svg" 
                alt="Success" 
                width={64} 
                height={64}
                className="mx-auto"
              />
            </motion.div>
          </div>

          {/* 텍스트 */}
          <div className="text-center mb-8">
            <motion.h3
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3, duration: 0.5 }}
              className="text-xl font-bold text-gray-900 mb-3"
            >
              {content[language].title}
            </motion.h3>
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4, duration: 0.5 }}
              className="text-gray-600 leading-relaxed"
            >
              {content[language].subtitle}
            </motion.p>
          </div>

          {/* 버튼들 */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.5 }}
            className="flex flex-col gap-3"
          >
            <Button
              onClick={handleSurveyClick}
              size="lg"
              className="w-full"
              style={{ backgroundColor: '#22B3A4' }}
            >
              {content[language].button}
            </Button>
            <button
              onClick={onClose}
              className="w-full py-2 text-sm text-gray-500 hover:text-gray-700 transition-colors"
            >
              {content[language].skip}
            </button>
          </motion.div>
        </motion.div>
        </div>
      )}
    </AnimatePresence>
  )

  return createPortal(modalContent, document.body)
}