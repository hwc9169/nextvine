'use client'

import { useState } from 'react'
import { Navigation } from '@/components/Navigation'
import { Hero } from '@/components/sections/Hero'
import { About } from '@/components/sections/About'
import { Features } from '@/components/sections/Features'
import { Interactive } from '@/components/sections/Interactive'
import { Solution } from '@/components/sections/Solution'
import { Monitoring } from '@/components/sections/Monitoring'
import { Services } from '@/components/sections/Services'
import { Reasons } from '@/components/sections/Reasons'
import { Contact } from '@/components/sections/Contact'
import { FullPageScroll } from '@/components/ui/FullPageScroll'
import { ScrollToTop } from '@/components/ui/ScrollToTop'
import { LanguageContext } from '@/lib/language-context'

export default function Home() {
  const [language, setLanguage] = useState<'ko' | 'en'>('ko')

  return (
    <LanguageContext.Provider value={{ language, setLanguage }}>
      <main className="relative overflow-x-hidden">
        {/* 네비게이션 */}
        <Navigation />

        {/* 풀페이지 스크롤 */}
        <FullPageScroll>
          {/* Hero 섹션 */}
          <Hero language={language} />

          {/* About 섹션 */}
          <About language={language} />

          {/* Features 섹션 */}
          <Features language={language} />

          {/* Interactive 섹션 */}
          <Interactive language={language} />

          {/* Solution 섹션 */}
          <Solution language={language} />

          {/* Monitoring 섹션 */}
          <Monitoring language={language} />

          {/* Services 섹션 */}
          <Services language={language} />

          {/* Reasons 섹션 */}
          <Reasons language={language} />

          {/* Contact 섹션 */}
          <Contact language={language} />
        </FullPageScroll>

        {/* Scroll To Top 버튼 */}
        <ScrollToTop />
      </main>
    </LanguageContext.Provider>
  )
}