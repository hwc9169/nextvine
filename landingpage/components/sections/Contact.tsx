'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Container } from '../ui/Container'
import { Button } from '../ui/Button'
import { SurveyModal } from '../ui/SurveyModal'
import Image from 'next/image'

interface ContactProps {
  language: 'ko' | 'en'
}

export function Contact({ language }: ContactProps) {
  const [formData, setFormData] = useState({
    email: '',
    targetAudience: '자녀',
    agreement: false
  })
  const [showSurveyModal, setShowSurveyModal] = useState(false)

  const content = {
    ko: {
      title: '우리 아이 척추건강, 곧 만나보세요',
      subtitle: '스콜리스캔 앱이 곧 출시됩니다!',
      subtitle2: '출시 소식을 가장 먼저 받아보시고, 우리 아이의 척추건강을 안전하게 관리하세요.',
      form: {
        email: '이메일',
        targetAudience: '누구를 위한 것인가요?',
        targetOptions: {
          child: '자녀',
          self: '본인',
          family: '다른 가족들'
        },
        agreement: '앱 출시 알림 및 서비스 정보 수신에 동의합니다.',
        submit: '앱 출시 알림 받기'
      }
    },
    en: {
      title: 'Meet Our Child\'s Spinal Health Soon',
      subtitle: 'Scoliscan app is coming soon!',
      subtitle2: 'Be the first to receive launch news and safely manage your child\'s spinal health.',
      form: {
        email: 'Email',
        targetAudience: 'Who is this for?',
        targetOptions: {
          child: 'Child',
          self: 'Self',
          family: 'Other Family Members'
        },
        agreement: 'I agree to receive app launch notifications and service information.',
        submit: 'Get Launch Notifications'
      }
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value
    })
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    console.log('Form submit clicked') // 디버깅용
    
    if (!formData.agreement) {
      alert(language === 'ko' ? '알림 및 서비스 정보 수신에 동의해주세요.' : 'Please agree to receive notifications and service information.')
      return
    }
    
    if (!formData.email) {
      alert(language === 'ko' ? '이메일을 입력해주세요.' : 'Please enter your email.')
      return
    }
    
    console.log('Form submitted:', formData)
    // 폼 제출 성공 후 설문조사 모달 표시
    setShowSurveyModal(true)
  }

  return (
    <div 
      className="min-h-screen lg:h-screen relative overflow-hidden flex items-center justify-center"
      style={{
        backgroundImage: 'url(/images/form-bg.svg)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat'
      }}
    >
      {/* Animated SVG Line Drawing */}
      <motion.div 
        className="absolute inset-0 pointer-events-none z-0"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        transition={{ delay: 0.5, duration: 1 }}
        viewport={{ once: false, amount: 0.3 }}
      >
        <svg 
          xmlns="http://www.w3.org/2000/svg" 
          width="1911" 
          height="343" 
          viewBox="0 0 1911 343" 
          className="hidden lg:block absolute top-1/3 left-0 w-full h-auto"
          fill="none"
        >
          <motion.path 
            d="M-66 39.9138C-61.6216 84.9353 -32.8257 122.62 1.21498 142.772C35.2557 162.924 74.0476 168.168 112.009 170.315C232.677 177.142 357.026 156.372 472.077 200.3C513.637 216.168 557.66 247.411 565.107 298.689C567.435 314.718 563.623 334.899 550.635 339.874C544.809 342.105 538.47 340.653 532.574 338.704C489.301 324.401 450.738 268.431 468.75 219.376C478.054 194.038 499.626 178.127 521.488 168.888C584.523 142.247 654.156 159.019 718.743 179.707C783.33 200.396 849.695 225.025 915.83 213.187C981.965 201.349 1047.59 139.561 1047.33 59.8052C1047.24 33.033 1033.92 1.22442 1011.48 2.01443C993.445 2.64924 980.558 25.972 981.26 47.4745C981.962 68.9759 992.529 88.1584 1004.01 104.756C1059.42 184.828 1144.48 232.066 1231.2 241.167C1317.91 250.267 1405.77 223.168 1482.46 174.05C1528.63 144.482 1571.42 106.961 1620.14 83.94C1714.55 39.3271 1827.59 56.0444 1910 126.807" 
            stroke="white" 
            strokeOpacity="0.7" 
            strokeWidth="2.3415" 
            strokeMiterlimit="10"
            fill="none"
            initial={{ pathLength: 0, strokeDasharray: "1 1" }}
            whileInView={{ pathLength: 1, strokeDasharray: "0 1" }}
            transition={{ duration: 3, ease: "easeInOut", delay: 1 }}
            viewport={{ once: false, amount: 0.3 }}
          />
        </svg>
      </motion.div>

      <Container size="1600" className="relative z-10 px-4 py-8 lg:py-0">
        <motion.div 
          className="text-center mb-6 sm:mb-8"
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: "easeOut" }}
          viewport={{ once: false, amount: 0.3 }}
        >
          <motion.h2 
            className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-3 sm:mb-4 leading-tight px-2"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2, ease: "easeOut" }}
            viewport={{ once: false, amount: 0.3 }}
          >
            {content[language].title}
          </motion.h2>
          <motion.p 
            className="text-base sm:text-lg lg:text-xl text-white/90 mb-2 px-2"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3, ease: "easeOut" }}
            viewport={{ once: false, amount: 0.3 }}
          >
            {content[language].subtitle}
          </motion.p>
          <motion.p 
            className="text-sm sm:text-base lg:text-lg text-white/80 px-2"
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.4, ease: "easeOut" }}
            viewport={{ once: false, amount: 0.3 }}
            dangerouslySetInnerHTML={{ __html: content[language].subtitle2 }}
          />
        </motion.div>

        {/* 폼 */}
        <motion.div
          className="mx-auto w-full max-w-[650px]"
          initial={{ opacity: 0, y: 60 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5, ease: "easeOut" }}
          viewport={{ once: false, amount: 0.3 }}
        >
          <div className="bg-white rounded-xl sm:rounded-2xl p-4 sm:p-6 lg:p-8 shadow-2xl">

            <form onSubmit={handleSubmit} className="space-y-4 sm:space-y-6">
              <motion.div
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5, delay: 0.1, ease: "easeOut" }}
                viewport={{ once: false, amount: 0.3 }}
              >
                <label className="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">
                  {content[language].form.email}
                </label>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  required
                  className="w-full px-3 sm:px-4 py-2 sm:py-3 text-sm sm:text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-colors"
                  placeholder={language === 'ko' ? '이메일을 입력하세요' : 'Enter your email'}
                />
              </motion.div>

              <motion.div
              >
                <label className="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">
                  {content[language].form.targetAudience}
                </label>
                <select
                  name="targetAudience"
                  value={formData.targetAudience}
                  onChange={handleInputChange}
                  required
                  className="w-full px-3 sm:px-4 py-2 sm:py-3 text-sm sm:text-base rounded-lg border border-gray-300 focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-colors"
                >
                  <option value="자녀">{content[language].form.targetOptions.child}</option>
                  <option value="본인">{content[language].form.targetOptions.self}</option>
                  <option value="다른 가족들">{content[language].form.targetOptions.family}</option>
                </select>
              </motion.div>

              <motion.div 
                className="flex items-start space-x-2 sm:space-x-3"
              >
                <input
                  type="checkbox"
                  name="agreement"
                  id="agreement"
                  checked={formData.agreement}
                  onChange={(e) => setFormData({ ...formData, agreement: e.target.checked })}
                  className="mt-0.5 sm:mt-1 w-3 h-3 sm:w-4 sm:h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                  required
                />
                <label htmlFor="agreement" className="text-xs sm:text-sm text-gray-600 leading-relaxed">
                  {content[language].form.agreement}
                </label>
              </motion.div>

              <motion.div
              >
                <Button
                  type="submit"
                  size="lg"
                  className="w-full flex items-center justify-center space-x-2 text-white hover:opacity-90 text-sm sm:text-base py-2 sm:py-3"
                  style={{ backgroundColor: '#22B3A4' }}
                  onClick={(e) => {
                    console.log('Button clicked directly')
                    handleSubmit(e as any)
                  }}
                >
                  <Image 
                    src="/images/icon-bell.svg" 
                    alt="Bell Icon" 
                    width={16} 
                    height={16}
                    className="filter brightness-0 saturate-100 invert sm:w-5 sm:h-5"
                  />
                  <span>{content[language].form.submit}</span>
                </Button>
              </motion.div>
            </form>
          </div>
        </motion.div>

      </Container>

      {/* Footer - 완전 하단에 너비 꽉차게 */}
      <div className="absolute bottom-0 left-0 right-0 bg-white h-20 sm:h-16 lg:h-20">
        <Container size="1600" className="h-full px-4 py-3 sm:py-2 lg:py-0">
          <div className="flex flex-col sm:flex-row items-center justify-between h-full gap-2 sm:gap-0">
            {/* 왼쪽: 저작권 */}
            <div>
              <p className="text-xs sm:text-sm text-gray-600 text-center sm:text-left">
                © 2025 ScolioScan. All rights reserved.
              </p>
            </div>

            {/* 오른쪽: 링크들 */}
            <div className="flex items-center space-x-4 sm:space-x-8">
              <button
                onClick={() => {}}
                className="text-xs sm:text-sm text-gray-600 hover:text-gray-900 transition-colors"
              >
                Privacy
              </button>
              <button
                onClick={() => {}}
                className="text-xs sm:text-sm text-gray-600 hover:text-gray-900 transition-colors"
              >
                Terms
              </button>
              <button
                onClick={() => {}}
                className="text-xs sm:text-sm text-gray-600 hover:text-gray-900 transition-colors"
              >
                Contact
              </button>
            </div>
          </div>
        </Container>
      </div>

      {/* 설문조사 모달 */}
      <SurveyModal 
        isOpen={showSurveyModal}
        onClose={() => setShowSurveyModal(false)}
        language={language}
      />
    </div>
  )
}