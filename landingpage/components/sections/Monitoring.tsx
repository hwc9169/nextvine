'use client'

import { motion } from 'framer-motion'
import { Container } from '../ui/Container'
import Image from 'next/image'

interface MonitoringProps {
  language: 'ko' | 'en'
}

export function Monitoring({ language }: MonitoringProps) {
  const content = {
    ko: {
      title: (
        <>
          집에서 시작하는 전문적인<br />
          척추 모니터링
        </>
      ),
      subtitle: '아이의 척추 건강은 초기부터 꾸준히 살펴보는 것이 가장 중요합니다. 스콜리스캔은 집에서 간단히 촬영한 사진을 AI가 분석하고, 그 결과를 전문의가 검토하여 정기적으로 관리할 수 있도록 돕습니다. 이제 병원에 자주 가지 않아도, 집과 병원이 연결된 새로운 방식의 척추 관리를 경험할 수 있습니다.'
    },
    en: {
      title: (
        <>
          Professional Spinal Monitoring<br />
          Starting at Home
        </>
      ),
      subtitle: 'Monitoring your child\'s spinal health consistently from an early stage is most important. Scoliscan helps AI analyze photos taken simply at home, with specialists reviewing the results for regular management. Now you can experience a new way of spinal care that connects home and hospital without frequent hospital visits.'
    }
  }

  return (
    <div className="h-full lg:flex lg:items-center lg:justify-center min-h-[800px] lg:min-h-screen bg-gray-50 relative overflow-hidden">
      {/* 모바일/태블릿용 gradient 배경 */}
      <div className="absolute inset-0 gradient-primary lg:hidden opacity-90" />
      {/* 배경 도형 - PC/노트북에서만 표시 */}
      <motion.div
        initial={{ x: '50vw', opacity: 0 }}
        whileInView={{ x: 0, opacity: 1 }}
        transition={{ duration: 0.8, delay: 0.2 }}
        className="hidden lg:block absolute bottom-[0%] right-0 gradient-primary rounded-tl-[300px]"
        style={{ 
          height: '90%', 
          width: '95%',
          zIndex: 1
        }}
      />

      <Container size="1600">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-16 items-center relative z-10 py-8 sm:py-12 lg:py-0">
          {/* 텍스트 콘텐츠 - 왼쪽 하단 */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="space-y-4 sm:space-y-6 p-4 sm:p-6 lg:self-end lg:pb-16 lg:p-20 order-2 lg:order-1"
          >
            <h2 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-white leading-tight">
              {content[language].title}
            </h2>
            <p className="text-sm sm:text-base lg:text-lg text-white leading-relaxed">
              {content[language].subtitle}
            </p>
          </motion.div>

          {/* 이미지 영역 - 오른쪽 */}
          <div className="relative h-[400px] sm:h-[500px] lg:h-[600px] overflow-visible order-1 lg:order-2">
            {/* PC 이미지 - sec6-pc - 데스크톱에서만 표시 */}
            <motion.div
              initial={{ x: 400, opacity: 0 }}
              whileInView={{ x: 0, opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="hidden lg:block absolute top-4 left-0 w-[1100px] h-[680px]"
            >
              <Image
                src="/images/sec6-pc.png"
                alt="PC Interface"
                fill
                className="object-contain"
              />
            </motion.div>

            {/* 모바일/태블릿용 앱 이미지 - sec6-app */}
            <div className="lg:hidden absolute top-16 right-4 w-36 h-72 sm:top-20 sm:right-8 sm:w-40 sm:h-80 md:top-24 md:right-12 md:w-52 md:h-[416px] z-50">
              <Image
                src="/images/sec6-app.png"
                alt="Mobile App"
                fill
                className="object-contain"
              />
            </div>
            
            {/* 데스크톱용 앱 이미지 */}
            <motion.div
              initial={{ x: 300, opacity: 0 }}
              whileInView={{ x: 0, opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.6 }}
              className="hidden lg:block absolute top-24 left-72 w-[350px] h-[600px]"
              style={{ zIndex: 40 }}
            >
              <Image
                src="/images/sec6-app.png"
                alt="Mobile App"
                fill
                className="object-contain"
              />
            </motion.div>

            {/* 모바일/태블릿용 심플 사진 - PC 이미지 대체 */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="lg:hidden absolute inset-0 flex items-center justify-center"
              style={{ zIndex: 10 }}
            >
              <div className="relative w-full h-full mx-auto">
                <Image
                  src="/images/sec6-pc.png"
                  alt="Mobile App Interface"
                  fill
                  className="object-contain"
                />
              </div>
            </motion.div>
          </div>
        </div>
      </Container>
    </div>
  )
}