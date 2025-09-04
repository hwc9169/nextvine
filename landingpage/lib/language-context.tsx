'use client'

import { createContext, useContext } from 'react'

// 언어 컨텍스트
export const LanguageContext = createContext<{
  language: 'ko' | 'en'
  setLanguage: (lang: 'ko' | 'en') => void
}>({
  language: 'ko',
  setLanguage: () => {}
})

export const useLanguage = () => useContext(LanguageContext)